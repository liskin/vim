" Tests for 'fixeol' and 'eol'

func Test_fixeol()
  " first write two test files – with and without trailing EOL
  " use Unix fileformat for consistency
  set ff=unix
  enew!
  call setline('.', 'with eol')
  w! XXEol
  enew!
  set noeol nofixeol
  call setline('.', 'without eol')
  w! XXNoEol
  set eol fixeol
  bwipe XXEol XXNoEol

  " try editing files with 'fixeol' disabled
  e! XXEol
  normal ostays eol
  set nofixeol
  w! XXTestEol
  e! XXNoEol
  normal ostays without
  set nofixeol
  w! XXTestNoEol
  bwipe! XXEol XXNoEol XXTestEol XXTestNoEol
  set fixeol

  " Append "END" to each file so that we can see what the last written char
  " was.
  normal ggdGaEND
  w >>XXEol
  w >>XXNoEol
  w >>XXTestEol
  w >>XXTestNoEol

  call assert_equal(['with eol', 'END'], readfile('XXEol'))
  call assert_equal(['without eolEND'], readfile('XXNoEol'))
  call assert_equal(['with eol', 'stays eol', 'END'], readfile('XXTestEol'))
  call assert_equal(['without eol', 'stays withoutEND'],
	      \ readfile('XXTestNoEol'))

  call delete('XXEol')
  call delete('XXNoEol')
  call delete('XXTestEol')
  call delete('XXTestNoEol')
  set ff& fixeol& eol&
  enew!
endfunc

func Test_setbufvar_eol()
  set ff=unix nofixeol

  call writefile(['noeol'], "XXNoEolSetEol", 'bS')
  e! XXNoEolSetEol
  set eol
  w! XXNoEolSetEol
  call assert_equal("noeol\n", join(readfile('XXNoEolSetEol', 'b'), "\n")) " XXX: fails

  call writefile(['noeol'], "XXNoEolSetEol2W", 'bS')
  e! XXNoEolSetEol2W
  set eol
  w! XXNoEolSetEol2W
  w! XXNoEolSetEol2W
  call assert_equal("noeol\n", join(readfile('XXNoEolSetEol2W', 'b'), "\n")) " XXX: passes (wtf)

  call writefile(['noeol'], "XXNoEol", 'bS')
  e! XXNoEol
  w! XXNoEol
  call assert_equal("noeol", join(readfile('XXNoEol', 'b'), "\n")) " XXX: passes (as it should)

  call writefile(['noeol'], "XXNoEol2W", 'bS')
  e! XXNoEol2W
  w! XXNoEol2W
  w! XXNoEol2W
  call assert_equal("noeol", join(readfile('XXNoEol2W', 'b'), "\n")) " XXX: passes (as it should)

  call writefile(['noeol'], "XXNoEolSetEolAppend", 'bS')
  e! XXNoEolSetEolAppend
  set eol
  call appendbufline('', '$', 'END')
  w! XXNoEolSetEolAppend
  call assert_equal("noeol\nEND\n", join(readfile('XXNoEolSetEolAppend', 'b'), "\n")) " XXX: passes (as it should)

  call writefile(['noeol'], "XXNoEolSetEolAppendDelete", 'bS')
  e! XXNoEolSetEolAppendDelete
  set eol
  call appendbufline('', '$', 'END')
  call deletebufline('', 2)
  w! XXNoEolSetEolAppendDelete
  call assert_equal("noeol\n", join(readfile('XXNoEolSetEolAppendDelete', 'b'), "\n")) " XXX: fails

  call writefile(['eol', ''], "XXEolSetNoEol", 'bS')
  e! XXEolSetNoEol
  set noeol
  w! XXEolSetNoEol
  call assert_equal("eol", join(readfile('XXEolSetNoEol', 'b'), "\n")) " XXX: passes (as it should)

  %bwipe!
  call delete('XXNoEolSetEol')
  call delete('XXNoEolSetEol2W')
  call delete('XXNoEolSetEolAppend')
  call delete('XXNoEolSetEolAppendDelete')
  call delete('XXNoEol')
  call delete('XXNoEol2W')
  call delete('XXEolSetNoEol')

  set ff& fixeol& eol&
endfunc

" vim: shiftwidth=2 sts=2 expandtab
