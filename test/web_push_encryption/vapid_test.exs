defmodule WebPushEncryption.VapidTest do
  use ExUnit.Case

  alias WebPushEncryption.Vapid

  test "get_headers" do

    assert %{"Authorization" => "WebPush " <> jwt,
      "Crypto-Key" => "p256ecdsa=" <> public_key} = Vapid.get_headers("http://localhost/", "aesgcm")

    options = %{alg: "ES256", key: Base.url_decode64!(public_key, padding: false)}
    assert {:ok, %{aud: _, exp: _, sub: _}} = JsonWebToken.verify(jwt, options)
  end

end
