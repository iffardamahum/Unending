# Seeds — idempotent, safe to re-run

dev_user = User.find_or_create_by!(email: "dev@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.admin = true
end
puts "✓ Dev user: dev@example.com / password123"

bin = dev_user.http_bins.find_or_create_by!(name: "Demo Bin") do |b|
  b.description = "Auto-generated demo bin for testing."
end
puts "✓ HTTP Bin: #{bin.name} — token: #{bin.token}"

[
  {
    name:            "Health check",
    http_method:     "GET",
    path_pattern:    "/health",
    response_status: 200,
    response_body:   '{"status":"ok"}',
    content_type:    "application/json"
  },
  {
    name:            "Mock users list",
    http_method:     "GET",
    path_pattern:    "/api/users*",
    response_status: 200,
    response_body:   '[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]',
    content_type:    "application/json"
  },
  {
    name:            "Create user (catch-all POST)",
    http_method:     "POST",
    path_pattern:    "/api/users",
    response_status: 201,
    response_body:   '{"id":3,"name":"Charlie","created":true}',
    content_type:    "application/json"
  }
].each do |attrs|
  bin.mock_rules.find_or_create_by!(
    http_method:  attrs[:http_method],
    path_pattern: attrs[:path_pattern]
  ) do |r|
    r.assign_attributes(attrs.merge(enabled: true, priority: 0))
  end
end
puts "✓ Sample mock rules created"
