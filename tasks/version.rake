# Returns array of version parts,
# or +nil+ if the passed string has invalid format
#
def s_to_version( str )
  m = str.match /^(\d+)\.(\d+)\.(\d+)$/
  if m
    [ m[1].to_i, m[2].to_i, m[3].to_i ]
  else
    nil
  end
end

# Returns version passed as an array in a canonical string representation. 
#
def version_to_s( arr )
  "%d.%d.%d" % [arr[0], arr[1], arr[2]]
end

desc "Show current gem version or set new version and commit to git"
task :version, [:new_version] do |t, args|
  VERSION_FILENAME = "version.txt"
  
  args.with_defaults :new_version => nil 
  old_version = s_to_version File.read( VERSION_FILENAME )
  if args.new_version
    # 1. everything is committed?
    unless `git status` =~ /nothing to commit/
      abort "ERROR: There are uncommitted changes, aborting"
    end  
    
    # 2. new version is in XX.YY.ZZ format?
    new_version = s_to_version args.new_version
    unless new_version
      abort "ERROR: New version \"#{args.new_version}\" is not in canonical format XX.YY.ZZ, aborting"
    end
    
    # 3. new version is greater than old one?
    unless (new_version <=> old_version) > 0
      abort "ERROR: New version \"#{version_to_s new_version}\" is not greater than the old \"#{version_to_s old_version}\", aborting"
    end
    
    # 4. OK, perform version bump 
    puts "v#{version_to_s old_version} => v#{version_to_s new_version}"
    
    File.open( VERSION_FILENAME, "w" ) {|f| f.puts args.new_version }
    system "git commit -a -m 'Version is now v#{version_to_s new_version}'"
    system "git tag v#{version_to_s new_version}"
    system "git push"
    system "git push --tags"
  else
    puts "v#{version_to_s old_version}"
  end
  true
end