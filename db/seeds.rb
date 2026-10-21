# Idempotent: safe to run again at any time. Production gets no demo data, so no account with a
# published password can exist on a real server.
if Rails.env.local?
  demo = User.find_or_create_by!(email: "demo@example.com") do |user|
    user.name = "Demo User"
    user.password = "demo-password-123"
    user.verified = true
  end

  [ "Website redesign", "Product launch" ].each do |name|
    demo.projects.find_or_create_by!(name: name)
  end
end
