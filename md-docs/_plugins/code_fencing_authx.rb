# Replace Jekyll's handling of the Redcarpet code_block (which already adds
# support for highlighting, but needs support for the very non-standard
# "code fences with line highlights" extension).
# Since this is currently depending on Redcarpet to cooperate, we are going to
# be naive, and only allow line highlighting when a language is specified. If
# you don't want any syntax highlighting but want to highlight lines, then you
# need to specify text as your language, like:
# ```text{4}


module Jekyll
  module Converters
    class Markdown
      class RedcarpetParser
      	module CommonMethods
					def add_code_tags(code, lang)
						code = code.to_s
						code = code.sub(/<pre>/, "<span class=\"stripe-display #{lang}\"><pre><code class=\"language-#{lang}\" data-lang=\"#{lang}\">")
						code = code.sub(/<\/pre>/, "</code></pre></span>")
						code
					end
				end
      end
    end
  end
end