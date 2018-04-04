defmodule WebPushEncryption.Vapid do

  @supported_encodings ~w(aesgcm) # aes128gcm not yet supported in push.ex

  def get_headers(audience, content_encoding, expiration \\ 12 * 3600, vapid \\ nil) when content_encoding in @supported_encodings do
    expiration_timestamp = DateTime.to_unix(DateTime.utc_now()) + expiration

    vapid = vapid || Application.fetch_env!(:web_push_encryption, :vapid_details)

    # public_key = Base.url_decode64!(vapid[:public_key], padding: false)
    private_key = Base.url_decode64!(vapid[:private_key], padding: false)
    byte_size(private_key)
    |> IO.inspect(label: "ss")

    payload = %{
      aud: audience,
      exp: expiration_timestamp,
      sub: vapid[:subject]
    }
    options = %{key: private_key, alg: "ES256"}
    jwt = JsonWebToken.sign(payload, options)

    headers(content_encoding, jwt, vapid[:public_key])
  end

  defp headers("aesgcm", jwt, pub) do
    %{"Authorization" => "WebPush " <> jwt, "Crypto-Key" => "p256ecdsa=" <> pub}
  end
  defp headers("aes128gcm", jwt, pub) do
    %{"Authorization" => "vapid t=#{jwt}, p=#{pub}"}
  end
end
