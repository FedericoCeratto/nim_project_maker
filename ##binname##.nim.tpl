## ##projname##
## Copyright ##author_name## <##email_addr##>
##

#import jester
import os,
  posix

onSignal(SIGABRT):
  ## Handle SIGABRT from systemd
  # Lines printed to stdout will be received by systemd and logged
  # Start with "<severity>" from 0 to 7
  echo "<2>Received SIGABRT"
  quit(1)

onSignal(SIGQUIT):
  echo "##projname## exiting..."
  quit(1)

#routes:
#  get "/":
#    resp "Hello world"
#
#when isMainModule:
#  runForever()

proc main() =
  echo "##projname## starting..."
  while true:
    sleep(10000)

when isMainModule:
  main()
