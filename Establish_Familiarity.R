if(!require('reticulate')) install.packages("reticulate")
library(reticulate)
use_python("/usr/local/bin/python")
# https://rstudio.github.io/reticulate/articles/versions.html


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

brown <- corpus$brown

py_help(corpus)

print(brown$words())
print(corpus)

py_run_string("x = 'unknown quantity'")
py$x

py_run_file("nltk0_eg.py")
py$nltkversion
