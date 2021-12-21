defmodule Advent21 do
  def read_starting_positions(file_name) do
    File.read!(file_name)
    |> String.split("\n")
    |> Enum.map(fn line ->
      line |> String.split(" ") |> Enum.at(4) |> String.to_integer()
    end)
    |> List.to_tuple()
  end

  def play({player0_starting_pos, player1_starting_pos}) do
    Stream.iterate(
      {0, 0, {player0_starting_pos, 0}, {player1_starting_pos, 0}},
      fn {last_dice_roll, player, {p0_pos, p0_score}, {p1_pos, p1_score}} ->
        roll = last_dice_roll * 3 + 6
        if player == 0 do
          new_pos = rem(p0_pos + roll - 1, 10) + 1
          {last_dice_roll + 3, 1 - player, {new_pos, p0_score + new_pos}, {p1_pos, p1_score}}
        else
          new_pos = rem(p1_pos + roll - 1, 10) + 1
          {last_dice_roll + 3, 1 - player, {p0_pos, p0_score}, {new_pos, p1_score + new_pos}}
        end
      end
    )
    |> Stream.drop_while(fn {_, _, {_, p0_score}, {_, p1_score}} ->
      p0_score < 1000 and p1_score < 1000
    end)
    |> Enum.at(0)
    |> then(fn {last_roll, _, {_, p0_score}, {_, p1_score}} ->
      last_roll * min(p0_score, p1_score)
    end)
  end

  # Keep track of all the possible game states (whose turn + positions and scores)
  # and how many universes led to it so far.
  # Iteratively take the state with the lowest score, run its splits, and merge
  # the new states & universe counts.
  def play_dirac(ongoing_states, won_states) when map_size(ongoing_states) == 0, do: won_states
  def play_dirac(ongoing_states, won_states) do
    {next_state_to_split, state_count} = ongoing_states
      |> Enum.min_by(fn {state, _} -> min(state.p0_score, state.p1_score) end)

    ongoing_states = Map.delete(ongoing_states, next_state_to_split)
    splits = DiracState.split(next_state_to_split)
    new_states = splits |> Enum.map(fn {state, count} -> {state, count * state_count} end)

    {ongoing_states, won_states} = new_states
      |> Enum.reduce({ongoing_states, won_states}, fn {new_state, count}, {ongoings, wons} ->
        if new_state.p0_score >= 21 or new_state.p1_score >= 21 do
          {ongoings, Map.update(wons, new_state, count, & &1 + count)}
        else
          {ongoings, Map.update(wons, new_state, count, & &1 + count)}
          {Map.update(ongoings, new_state, count, & &1 + count), wons}
        end
      end)

    play_dirac(ongoing_states, won_states)
  end

  def dirac_number_of_winning_universes({p0_starting_pos, p1_starting_pos}) do
    {p0_wins, p1_wins} =
      %{DiracState.new(p0_starting_pos, p1_starting_pos) => 1}
      |> play_dirac(%{})
      |> Enum.reduce({0, 0}, fn {state, count}, {p0_wins, p1_wins} ->
        if state.p0_score > state.p1_score do
          {p0_wins + count, p1_wins}
        else
          {p0_wins, p1_wins + count}
        end
      end)

    max(p0_wins, p1_wins)
  end
end

defmodule DiracState do
  defstruct [:turn, :p0_pos, :p0_score, :p1_pos, :p1_score]

  def new(p0_pos, p1_pos) do
    %DiracState{
      turn: 0,
      p0_pos: p0_pos,
      p0_score: 0,
      p1_pos: p1_pos,
      p1_score: 0
    }
  end

  def split(state) do
    roll_counts = (for r1 <- 1..3, r2 <- 1..3, r3 <- 1..3, do:
      r1 + r2 + r3
    ) |> Enum.frequencies()
    if state.turn == 0 do
      roll_counts
      |> Enum.map(fn {roll, count} ->
        new_pos = rem(state.p0_pos + roll - 1, 10) + 1
        {
          %DiracState{state | turn: 1, p0_pos: new_pos, p0_score: state.p0_score + new_pos},
          count
        }
      end)
    else
      roll_counts
      |> Enum.map(fn {roll, count} ->
        new_pos = rem(state.p1_pos + roll - 1, 10) + 1
        {
          %DiracState{state | turn: 0, p1_pos: new_pos, p1_score: state.p1_score + new_pos},
          count
        }
      end)
    end
  end
end

input = Advent21.read_starting_positions("input/21.txt")
input |> Advent21.play() |> IO.inspect()
input |> Advent21.dirac_number_of_winning_universes() |> IO.inspect()
