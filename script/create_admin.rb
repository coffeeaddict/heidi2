#!script/rails runner
#

if User.count > 0
  puts "There already are users on the system"
  exit 0
end

puts "Creating an admin user\n\n"
print "Email: "
email = gets

print "\nPassword: "
password = gets

print "\n"

user = User.create( email: email, password: password )
if user.valid?
  puts "All done. You can now login."
else
  puts "User invalid: #{user.errors}"
end
