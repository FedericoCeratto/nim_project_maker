## Nim project maker

import os,
  osproc,
  parseopt,
  strutils

proc splitPathComponents(p: string): seq[string] =
  if p.isAbsolute:
    result = p.split({DirSep, AltSep})[1..^1]
  else:
    result = p.split({DirSep, AltSep})
  if result.len > 0 and result[^1] == "":
    result = result[0..^2]

proc discover_pkg_path(): string =
  ## Discover the Nimble path or equivalent for the current binary
  # getAppFilename follows symlinks
  # A Nimble-deployed binary is usually at <dir>/.nimble/pkgs/<pkgname-version>/<executable>
  let fn = getAppFilename()
  let comp = splitPathComponents(fn)
  if comp.len > 3 and comp[^4] == ".nimble" and comp[^3] == "pkgs":
    return fn.parentDir()
  raise newException(Exception, "error")

proc help(i=0) =
  echo """
Usage: $# <project-name>

  """ % getAppFilename()
  quit(i)

iterator tpl_files(tpl_dir: string): string =
  for fn in tpl_dir.walkDirRec():
    if not fn.endswith(".tpl"):
      continue
    yield fn


proc main() =
  var projname = ""
  var gh_url = ""

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      projname = key
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        help()
    else: discard
  let binname = projname.normalize()
  if binname == "":
    help(1)

  var (author_name, _) = execCmdEx("git config --global user.name")
  var (email_addr, _) = execCmdEx("git config --global user.email")
  author_name = author_name.strip()
  email_addr = email_addr.strip()

  create_dir(projname)
  set_current_dir(projname)
  doAssert exec_shell_cmd("git init .") == 0
  let gh_username = getEnv("GH_USERNAME")
  if gh_username != "":
    gh_url = "https://github.com/$#/$#" % [gh_username, projname]
    let cmd = "git remote add origin git@github.com:$#/$#.git" % [gh_username, projname]
    doAssert exec_shell_cmd(cmd) == 0

  let tpl_dir = discover_pkg_path()
  for tpl_fn in tpl_dir.tpl_files():
    # trim shared path and trailing ".tpl"
    let dst_fn = tpl_fn[tpl_dir.len+1..^5]
    # create dir if needed
    dst_fn.splitFile.dir.createDir()

    let data = tpl_fn.readFile.multiReplace({
      "##projname##": projname,
      "##binname##": binname,
      "##author_name##": author_name,
      "##email_addr##": email_addr,
      "##gh_url##": gh_url
    })
    let real_dst_fn = dst_fn.multiReplace({
      "##projname##": projname,
      "##binname##": binname
    })
    writeFile(real_dst_fn, data)

  doAssert exec_shell_cmd("nimble init $#" % binname) == 0

  let nimble_file = readFile binname & ".nimble"
  let add_to_nimble_orig = """
bin       = @["##binname##"]
task build_deb, "build deb package":
  exec "dpkg-buildpackage -us -uc -b"

task install_deb, "install deb package":
  exec "sudo debi"
"""
  let add_to_nimble = add_to_nimble_orig.multiReplace({
    "##projname##": projname,
    "##binname##": binname
  })
  writeFile(binname & ".nimble", nimble_file & add_to_nimble)





when isMainModule:
  main()
