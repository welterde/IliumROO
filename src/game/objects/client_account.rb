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

require 'database/game_objects'
require 'database/system_logging'
require 'game_objects/game_object_loader'
require 'date'

class ClientAccount < BasicPersistentGameObject
  PROPERTIES = [:email, :password, :last_login_date, :last_login_ip, :display_type, :characters, :account_type].freeze
  attr_accessor :email, :password, :last_login_date, :last_login_ip, :display_type, :characters, :account_type

  def initialize
    super
    @display_type ||= "ANSI"
    @account_type ||= "normal"
  end

  def save
    super
    GameObjects.add_tag 'accounts', self.email, {'object_id' => self.game_object_id}
  end

  def add_new_character(name)
    # create the new character object
    # TODO: change this line to reflect new starting class
    new_character = BasicNamedObject.new
    new_character.name = name
    new_character.owner = self.game_object_id
    new_character.object_tag = :player_names
    new_character.master = true
    new_character.save

    # add new character to our collection
    if @characters.nil?
      @characters = new_character.game_object_id
    else
      @characters << "," << new_character.game_object_id
    end
    save

    # add the log entry
    SystemLogging.add_log_entry "created new character", self.game_object_id, new_character.game_object_id
  end

  def remove_character(character_id)
    c_list = @characters.split(",")
    c_name = get_player_name(character_id)
    SystemLogging.add_log_entry "deleted character #{c_name}", self.game_object_id, character_id
    c_list.delete character_id
    @characters = c_list.join(",")
    @characters = nil if @characters.empty?
    save
  end

  def name_available?(the_name)
    player_name = GameObjects.get_tag 'player_names', the_name
    return true if player_name.empty?
    false
  end

  def get_player_name(game_object_id)
    player_hash = GameObjects.get game_object_id
    player_hash['name']
  end

  def delete_character(game_object_id)
    c_name = get_player_name game_object_id
    GameObjects.remove game_object_id
    GameObjectLoader.remove_from_cache game_object_id
    GameObjects.remove_tag 'player_names', c_name
  end
  
  def set_last_login(client_ip)
    @last_login_ip = client_ip
    @last_login_date = DateTime.now.strftime
    save

    # add the log entry
    SystemLogging.add_log_entry "logged in account", self.game_object_id
  end

  def self.get_account_id(email_address)
    account = GameObjects.get_tag 'accounts', email_address
    return nil if account.empty?
    account['object_id']
  end

  def self.create_new_account(email_address, password)
    client_account = ClientAccount.new
    client_account.password = password
    client_account.email = email_address
    client_account.save

    SystemLogging.add_log_entry "created new account", client_account.game_object_id
    client_account
  end

  def self.get_account(account_object_id)
    GameObjectLoader.load_object account_object_id
  end

  def self.account_count()
    accounts = GameObjects.get_tags 'accounts'
    accounts.length
  end
end