module Runners
  module Schema
    Options = _ = StrongJSON.new do
      # @type self: OptionsClass

      let :source, object(
        head: string,
        base: string?,
        git_url: string,
        git_url_userinfo: string?,
        refspec: enum?(string, array(string)),
      )

      let :payload, object(
        source: source,
        outputs: array?(string),
        ssh_key: string?,
        s3: object?(endpoint: string),
      )
    end
  end
end
