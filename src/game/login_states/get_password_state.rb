#  This file is part of Ilium MUD.
#
#  Ilium MUD is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  Ilium MUD is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Ilium MUD.  If not, see <http://www.gnu.org/licenses/>.

require 'singleton'
require 'game/objects/client_account'
require 'game/utils/password'
require 'game/account_states/main_menu_state'
require 'game/account_states/logout_state'

class GetPasswordState
  include Singleton

  def enter(entity)
    entity.send_to_client "Password:"
  end

  def exit(entity)
  end

  def execute(entity)
    client_account = ClientAccount.get_account entity.account
    if Password::check(entity.last_client_data, client_account.password)
      entity.send_to_client "Last login from #{client_account.last_login_ip} on #{client_account.last_login_date}\n"
      client_account.set_last_login entity.client.client_ip

      client_account.attach_client entity.client
      entity.detach_client
      
      client_account.change_state MainMenuState
    else
      entity.ctr += 1
      if entity.ctr >= 3
        entity.change_state LogoutState
      else
        entity.send_to_client "Invalid password.\n"
        entity.change_state GetPasswordState
      end
    end
  end
end