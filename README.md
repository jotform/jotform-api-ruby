jotform-api-ruby 
===============
[JotForm API](http://api.jotform.com/docs/) - Ruby Client


### Installation

Install via git clone:

        $ git clone git://github.com/jotform/jotform-api-ruby.git
        $ cd jotform-api-ruby

### Documentation

You can find the docs for the API of this client at [http://api.jotform.com/docs/](http://api.jotform.com/docs)

### Authentication

JotForm API requires API key for all user related calls. You can create your API Keys at  [API section](http://www.jotform.com/myaccount/api) of My Account page.

### Examples

Print all forms of the user
    
```ruby
#!/usr/bin/env ruby
require_relative 'JotForm'

jotform = JotForm.new("APIKey")
forms = jotform.getForms()

forms.each do |form|
    puts form["title"]
end
```    

Get latest submissions of the user
    
```ruby
#!/usr/bin/env ruby
require_relative 'JotForm'

jotform = JotForm.new("APIKey")
submissions = jotform.getSubmissions()

submissions.each do |submission|
    puts submission["created_at"] + " " 
    submission["answers"].each do | answer|
        puts "\t" + answer.join(" ")
    end
end
```    

    
First the _JotForm_ class is included from the _jotform-api-ruby/JotForm.rb_ file. This class provides access to JotForm's API. You have to create an API client instance with your API key. 
In any case of exception (wrong authentication etc.), you can catch it or let it fail with fatal error.
