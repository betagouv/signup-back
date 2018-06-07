def nano_timestamp_email(options={domain: 'mail.com'})
  "#{nano_timestamp_string}@#{options[:domain]}"
end

def nano_timestamp_string
  Time.now.to_f.to_s.sub('.','')
end
