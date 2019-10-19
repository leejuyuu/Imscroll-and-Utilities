function sub_dir_names = list_subdirectories(dir_in)
dir_contents = dir(dir_in);
is_dir = [dir_contents(:).isdir];
sub_dir_names = {dir_contents(is_dir).name};
sub_dir_names = sub_dir_names(~ismember(sub_dir_names,{'.','..'}));


end