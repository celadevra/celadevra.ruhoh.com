guard 'livereload' do
  watch(%r{posts/.+\.(textile|markdown|md|html)})
end

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{theme/twitter/stylesheets/.+\.(css|js|html)})
  watch(%r{theme/twitter/media/.+\.(jpg|png|gif)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)/assets/\w+/(.+\.(css|js|html)).*})  { |m| "/assets/#{m[2]}" }
end
