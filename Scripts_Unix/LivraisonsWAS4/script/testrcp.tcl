#
#test de kla commande rcp via un script TCL pour wscp
#
proc testrcp {} {
exec rcp -p wasObject3.ksh fexploit@fsmiami:/fsmiami/product/websphere/v4.0.3/installedApps
set machine [exec hostname]
puts "nous sommes sur le serveur $machine"
}
