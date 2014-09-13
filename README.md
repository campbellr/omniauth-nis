# OmniAuth NIS

Use the NIS strategy as a middleware in your application:

    use OmniAuth::Strategies::NIS,
        :title => "My NIS",
        :domain => 'mydomain'

Directs users to '/auth/nis' to have them authenticated via your company's NIS server.

Heavily inspired by omniauth-ldap.
