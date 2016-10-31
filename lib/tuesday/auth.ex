# Maybe I'll deprecate this whole module in favor of Guardian...
defmodule Tuesday.Auth do
  import Tuesday.Web.Util, only: [get_now: 0]

  @expire_minutes 60
  @secret Application.get_env(:tuesday, Tuesday.Web.Endpoint)
          |> Keyword.get(:auth_secret)

  # def authenticate({user, pass}) do
  #
  # end

  def generate_token(user_id, now \\ get_now(), secret \\ @secret) do
    user_id_s = user_id |> to_string
    now_s     = now     |> to_string
    content   = user_id_s <> now_s <> secret
    hash      = hash(content) |> String.slice(0..10)

    user_id_s <> "," <> now_s <> "," <> hash
  end

  def verify_token(token, now \\ get_now(), secret \\ @secret) do
    case token |> String.split(",") do
      [user_id, stamp, _hash] ->
        user_id = user_id |> Integer.parse |> elem(0)
        stamp   = stamp   |> Integer.parse |> elem(0)
        valid?  = token == generate_token(user_id, stamp, secret)
        expired? = stamp_expired?(stamp, now)

        case valid? and not expired? do
          true  -> user_id
          false -> false
        end
      _ ->
        false
    end
  end

  @doc """
  Hash a string, with salt.
  """
  def hash(str) when is_binary(str) do
    :crypto.hash(:sha256, str <> @secret)
    |> Base.encode64
  end

  def stamp_expired?(stamp, now) do
    minutes_old = (now - stamp) / 60
    cond do
      minutes_old > @expire_minutes -> true
      true                          -> false
    end
  end
end
