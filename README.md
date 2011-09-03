# Tipsy

Tipsy is a small Rack-based server inspired by gems like StaticMatic and Serve. Its purpose is to aid development of static sites by providing 
Rails-esque style templating and helpers. Various template types are supported via the Tilt gem, and assets are served via Sprockets, essentially giving you 
a miniture Rails "view-only" environment. 

Any template format Tilt provides should work without much hassle. ERB (via Erubis) is provided. Note Erubis is required to make ERB function properly as 
we've applied some of the same modifications as Rails, allowing things like block style helpers such as

	<%= capture do %>
		something
	<% end %>	

which would error normally. By doing so it should make integration with any number of ActionView style helpers fairly simple.

## Usage

**Creating** To create a new site run `tipsy new name_of_site` to generate a new site in the current directory.

**Compiling** To compile the site into a production-ready state, run `tipsy compile` from the site's root directory.

**Serving** Simply run `tipsy` from the site root. Its recommended to add Thin or Mongrel to your Gemfile but Webrick will be used as a fallback.

Running the site generator should provide all of the configuration and setup options you would need to get started. Check out config.rb in the created 
site's root for more info. 

### Notes

Tipsy was developed for personal/internal use but feature/pull requests are gladly accepted. It is not designed to function in any kind of production 
environment. When ready to upload files to a production environment, build the project and upload the result.

By default *most* ActionView compatible helpers should work out of the box... with the exception of helpers extending things like the form builder etc. 
Right now Tipsy has no form builder, so you would have to provide your own. 