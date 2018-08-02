if(!require('reticulate')) install.packages("reticulate")
library(reticulate)

sys <- import("sys")
#use_python("/usr/local/bin/python3")
#use_python("/usr/local/opt/python/bin/python3.7")
sys$version
# https://rstudio.github.io/reticulate/articles/versions.html
py_config()
reticulate::py_discover_config()

py_run_string("print (sys.version)")

# Natural Language Tool Kit -----------------------------------------------


nltk <- import("nltk")

nltk

## enter Python reads, evaluates, prints, and loops back to reading
repl_python()

### >>> my_q = 59.99983
### exit REPL with <code>exit</code>

# check python result through "py" object
py$my_q

corpus <- import("nltk.corpus")
np <- import(numpy, convert=FALSE)
brown <- corpus$brown

py_help(corpus)

print(brown$words())
print(corpus)

py_run_string("x = 'unknown quantity'")
py$x

py_run_file("nltk0_eg3.py")
py$nltkversion

# Attempt to call chatbots ------------------------------------------------

nltk$chat$chatbots()  # notding happens

repl_python()    # trying nltk.chat.chatbots() presents menu but does not accept input



# Explore python config ---------------------------------------------------

import("sys")

#the C api
py$sys$api_version
py$sys$version
py$sys$version_info
py$sys$exec_prefix
py$sys$executable
py$sys$argv  
py$sys$builtin_module_names
py$sys$flags
py$sys$byteorder
py$sys$copyright
py$sys$dont_write_bytecode
py$sys$float_info

py$sys$modules
py$sys$maxsize
py$sys$path
py$sys$platform
py$sys$winver

# R
py$R
py$r

py$sys$getsizeof(nltk)
py$sys$getrecursionlimit()

repl_python()
nltk$download()
