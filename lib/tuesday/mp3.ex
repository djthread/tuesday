defmodule Tuesday.MP3 do
  alias Tuesday.MP3
  alias Tuesday.Show
  alias Tuesday.Episode
  alias Tuesday.Web.Util

  defstruct filename: nil,
            size_mb: nil,
            time: nil,
            codec: nil,
            kbps: nil,
            hz: nil,
            stereo: nil,
            id3v: nil,
            title: nil,
            artist: nil,
            album: nil,
            album_artist: nil,
            date: nil,
            track: nil,
            genre: nil,
            recording_date: nil

  def get_meta(full_filename) do
    [filename] = Regex.run(~r/[^\/]+$/, full_filename)

    case File.exists?(full_filename) do
      true ->
        lines =
          Sh.eyeD3("--no-color", full_filename)
          |> String.split("\n")

        parse(%MP3{filename: filename}, lines)

      _ ->
        %{msg: filename <> " could not be found."}
    end
  end

  def write_tags_if_file_exists(ep = %Episode{}, show = %Show{}) do
    require Logger

    full_filename = Util.podcast_path_by_slug(show.slug, ep.filename)

    case full_filename |> File.exists?() do
      true ->
        args = [
          "--no-color",
          "--to-v2.4",
          "-a",
          fix(ep.title) || "",
          "-A",
          fix(show.podcast_name) || "",
          "-t",
          "#{fix(ep.number)}. #{fix(show.name)} [#{fix(ep.record_date)}]",
          "-G",
          fix(show.genre) || "",
          "-Y",
          elem(Date.to_erl(ep.record_date), 0),
          "--recording-date",
          Date.to_iso8601(ep.record_date),
          "--remove-all-comments",
          "--add-comment",
          fix(ep.description) || "",
          full_filename
        ]

        Logger.info("eyeD3 cmd: #{inspect(args)}")

        apply(Sh, :eyeD3, args)

        # Sh.eyeD3("--no-color", "--to-v2.4",
        #   "-a", fix(ep.title) || "",
        #   "-A", fix(show.podcast_name) || "",
        #   "-t", "#{fix(ep.number)}. #{fix(show.name)} [#{fix(ep.record_date)}]",
        #   "-G", fix(show.genre) || "",
        #   "-Y", ep.record_date
        #         |> fix
        #         |> Ecto.Date.cast!
        #         |> Calendar.Strftime.strftime("%Y")
        #         |> elem(1),
        #   "--recording-date", ep.record_date |> fix |> Date.to_iso8601,
        #   "--remove-all-comments",
        #   "--add-comment", fix(ep.description) || "",
        #   full_filename)
        # |> Logger.info

        true

      _ ->
        false
    end
  end

  # Normalize a string for eyeD3
  defp fix(str) when is_binary(str) do
    # strip non-ascii characters
    String.replace(str, ~r/[^\x00-\x7F]+/, "")
  end

  defp fix(something_else), do: something_else

  defp parse(
         [
           "-------------------------------------------------------------------------------"
           | tail
         ],
         meta = %MP3{}
       ) do
    parse(tail, meta)
  end

  defp parse(meta = %MP3{}, [line = "Time: " <> _the_rest | tail]) do
    rx = ~r/^Time: ([\d:]+)\t(.*?)\t\[ (\d+) kb.s @ (\d+) Hz - (.*) \]$/

    case Regex.run(rx, line) do
      [_, time, codec, kbps, hz, stereo] ->
        %{meta | time: time, codec: codec, kbps: kbps, hz: hz, stereo: stereo}

      _ ->
        meta
    end
    |> parse(tail)
  end

  defp parse(meta = %MP3{}, ["ID3 " <> id3v | tail]) do
    parse(%{meta | id3v: String.trim_trailing(id3v, ":")}, tail)
  end

  defp parse(meta = %MP3{}, ["title: " <> title | tail]) do
    parse(%{meta | title: title}, tail)
  end

  defp parse(meta = %MP3{}, ["artist: " <> artist | tail]) do
    parse(%{meta | artist: artist}, tail)
  end

  defp parse(meta = %MP3{}, ["album: " <> album | tail]) do
    parse(%{meta | album: album}, tail)
  end

  defp parse(meta = %MP3{}, ["album artist: " <> album_artist | tail]) do
    parse(%{meta | album_artist: album_artist}, tail)
  end

  defp parse(meta = %MP3{}, ["recording date: " <> date | tail]) do
    parse(%{meta | recording_date: date}, tail)
  end

  defp parse(meta = %MP3{}, ["release date: " <> date | tail]) do
    parse(%{meta | date: date}, tail)
  end

  defp parse(meta = %MP3{}, [line = "track: " <> _the_rest | tail]) do
    rx = ~r/^track: (.*?)\t\tgenre: (.*?) \(id /

    case Regex.run(rx, line) do
      [_, track, genre] ->
        %{meta | track: track, genre: genre}

      _ ->
        meta
    end
    |> parse(tail)
  end

  defp parse(meta = %MP3{filename: fname}, [line | tail]) do
    case Regex.run(~r/#{fname}\t\[ ([\d\.]+) MB \]/, line) do
      [_, size_mb] -> %{meta | size_mb: size_mb}
      _ -> meta
    end
    |> parse(tail)
  end

  defp parse(meta = %MP3{}, []), do: meta

  # def parse(file_name) do
  #   case File.read(file_name) do
  #     {:ok, binary} ->
  #       mp3_byte_size = (byte_size(binary) - 128)
  #       << _ :: binary-size(mp3_byte_size), id3_tag :: binary >> = binary
  #
  #       << "TAG",
  #           title   :: binary-size(30), 
  #           artist  :: binary-size(30), 
  #           album   :: binary-size(30), 
  #           year    :: binary-size(4), 
  #           comment :: binary-size(30), 
  #           _rest   :: binary >> = id3_tag
  #
  #       IO.puts title
  #       IO.puts artist 
  #       IO.puts album 
  #       IO.puts year 
  #       IO.puts comment 
  #
  #     _ -> 
  #       IO.puts "Couldn't open #{file_name}"
  #   end
  # end

  # @moduledoc """
  # Shamelessly borrowed from
  # https://github.com/anisiomarxjr/shoutcast_server/blob/master/lib/mp3_file.ex
  # """
  #
  # def extract_metadata(file) do
  #   read_file = File.read!(file)
  #   file_length = byte_size(read_file)
  #   music_data = file_length - 128
  #   << _ :: binary-size(music_data), id3_section :: binary >> = read_file
  #   id3_section
  # end
  #
  # defp parse_id3(metadata) do
  #   << _ :: binary-size(3), title :: binary-size(30), artist :: binary-size(30), album :: binary-size(30), _ :: binary >> = metadata
  #   %{
  #     title: sanitize(title),
  #     artist: sanitize(artist),
  #     album: sanitize(album)
  #   }
  # end
  #
  # defp sanitize(text) do
  #   not_zero = &(&1 != <<0>>)
  #   text |> String.graphemes |> Enum.filter(not_zero) |> to_string |> String.strip
  # end
  #
  # def extract_id3(file) do
  #   metadata = extract_metadata(file)
  #   parse_id3(metadata)
  # end
  #
  # def extract_id3_list(folder) do
  #   folder |> list |> Enum.map(&extract_id3/1)
  # end
  #
  # def list(folder) do
  #   folder |> Path.join("**/*.mp3") |> Path.wildcard
  # end
end
