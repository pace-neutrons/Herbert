% Test parse_keyval

keywords = {'alldata','sum','integrate'};

keyval = parse_keyval (keywords)

keyval = parse_keyval (keywords,'all',[13,14])

keyval = parse_keyval (keywords,'sum',{'fart!',true},'all',[13,14])


keyval = parse_keyval (keywords,'sum',{'fart!',true},'all',[13,14],'sum',11)

keyval = parse_keyval (keywords,'sum',{'fart!',true},'all',[13,14],'integrate')



% Test parse_flags

flagnames = {'alldata','sum','integrate','alleycat', 'all'};


flags = parse_flags (flagnames, 'al')

flags = parse_flags (flagnames, 'all')

flags = parse_flags (flagnames, 'all', 'poop')

flags = parse_flags (flagnames, 'sum', 'all')

flags = parse_flags (flagnames, 'sum', 'all', 'su')








