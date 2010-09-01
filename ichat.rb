#!/usr/local/bin/macruby
framework 'ScriptingBridge'
app = SBApplication.applicationWithBundleIdentifier("com.apple.iChat")
original_status = app.statusMessage
new_year = Time.mktime(2010, 1, 1, 0, 0)
 
loop do
  now = Time.now
  time_left = (new_year - now).ceil
  if time_left > 0
    app.statusMessage = "#{time_left} seconds left until 2010 (EST)"
  else
    app.statusMessage = "Happy New Year 2010!"
    exit
  end
  sleep(1)
end