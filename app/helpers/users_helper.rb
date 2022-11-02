module UsersHelper
  def get_data_for_users_csv
    temp = []
    @users.each do |user|
      first = user.id
      second = user&.roles&.first
      third = user.name
      fourth = user.user_name
      fifth = user.email
      sixth = user.email_to
      seventh = user.father_name
      eightth = user.phone
      temp.push([first, second, third, fourth, fifth, sixth, seventh, eightth])
    end
    return temp
  end
end
