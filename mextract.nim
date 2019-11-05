import cligen, strutils, os, osproc

const
    BLIST = """borg list "$repo" --last $lastn --short""" #repo, lastn
    EXTRACT = """borg extract "$repo::$archive" "$file" --stdout > "$target""""
    FLIST = """borg list "$repo::$archive" "$file""""


proc list(repo: string, lastn: int): seq[string] =
    let (outp, errC) = execCmdEx(BLIST % ["repo", repo, "lastn", $lastn])
    if errC != 0:
        echo "Could not list repos (locked?)"
        quit()
    result = outp.splitLines()

proc listFile(repo: string, filename: string, lastn: int) =
    for archive in list(repo, lastn):
        if archive.strip().len == 0: continue
        let cmd = FLIST % ["repo", repo, "archive", archive, "file", filename]
        echo cmd
        let (outp, errC) = execCmdEx(cmd)
        if errC != 0:
            echo "Could not list file (locked?)"
            # quit()
        echo outp
        echo "############################"

proc extractFile(repo: string, archives: seq[string], filename, tofolder: string, dryRun: bool) =
    createDir(tofolder)
    for archive in archives:
        if archive.strip.len == 0: continue
        # echo "archive"
        let cmd = EXTRACT % [
            "repo", repo,
            "archive", archive,
            "target",  tofolder / archive.replace(" ", "_") & "___" & filename.splitPath().tail,
            "file", filename
        ]
        echo cmd
        if not dryRun:
            discard execCmdEx(cmd)


proc extract(repo: string, filename: string, tofolder: string = "/tmp/mextract/", lastn = 100, dryRun: bool = true) =
    discard
    let archives = list(repo, lastn)
    extractFile(repo, archives, filename, tofolder, dryRun)

dispatchMulti([extract], [listFile])
