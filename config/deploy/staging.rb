# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

#role :app, %w{medusatest.library.illinois.edu}
#role :web, %w{medusatest.library.illinois.edu}
#role :db,  %w{medusatest.library.illinois.edu}


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

set :home, '/home/lib-medusa-collectionregistry'
set :deploy_to, "#{fetch(:home)}/medusa-cr-capistrano"
set :bin, "#{fetch(:home)}/bin"

server 'medusatest.library.illinois.edu', user: 'lib-medusa-collectionregistry', roles: %w{web app db}, primary: true
#server 'medusatest.library.illinois.edu', user: 'medusa', roles: %w{web app db}, primary: true
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
