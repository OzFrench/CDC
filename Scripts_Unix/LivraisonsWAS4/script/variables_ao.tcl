#
#
#  Example de fichier de variables WSCP pour WAS 4.x
#
#

#
#    NOEUD WEBSPHERE
#
set nodeName fsdevelop2
set fullNodeName "/Node:$nodeName/"


#
#    VIRTUAL HOST
#
# Nom du Virtual Host
set vhName fssydney
 
# Liste des Alias
set aliaslist [list *:9084 *:10080 *:9080 fssydney:5080]

# Ici on pourra ajouter d'autres types d'attributs 
# par exemple une MIMETABLE

 
# Listes des Attributs du Virtual Host
set aliasattr [list AliasList $aliaslist]

set VHattributelist [list $aliasattr]


#
#    APPLICATION SERVER
#

# Nom de l'ApplicationServer
set asName "AgenceOPCVM_rim"
set fullAsName "/Node:$nodeName/ApplicationServer:$asName/"

# Configuration de la JVM
set minheapattr [list InitialHeapSize 32]
set maxheapattr [list MaxHeapSize 64]
set heapattr [list $minheapattr $maxheapattr]
set jvmconfigattr [list JVMConfig $heapattr]

# fichier de sortie standard
set Out "/fsdevelop2/dev/was4test/logs/test_stdout"
set stdout [list Stdout $Out]

# Fichier de sortie d'erreur
set Err "/fsdevelop2/dev/was4test/logs/test_stderr"
set stderr [list Stderr $Err]


# Parametres du Plugin HTTP
#
# Port d'ecoute
set portattr [list Port 5080]
set httptransattr [list $portattr]
set transportattr [list Transports $httptransattr]

set webcontainerattr [list WebContainerConfig $transportattr]

# Liste des attributs de l'ApplicationServer
set ASattributelist [list $jvmconfigattr $stdout $stderr $webcontainerattr]


#
# EntrepriseApplication
#

# Nom et chemin du fichier EAR
set instdir "/fsdevelop2/dev/was4test/integration/EARinstall/"
set earfile "AgenceOPCVM_rim.ear"
set earName "$instdir$earfile"

# Nom de l'EnterpriseApp
set eaName "AgenceOPCVM_rim"

# Nom du ou des modules WAR
set warName1 "Agence.war"

# Association du module War avec le VirtualHost
set modvirthost1 [list $warName1 $vhName]
set modvirthosts [list $modvirthost1]



#
# JDBC DRIVER
#

# Variables parametrables

set jdbcDriverName [list {Driver FS_SV_AGF}]
set implClass [list ImplClass com.sybase.jdbc2.jdbc.SybConnectionPoolDataSource]
set driverDescription [list Description {FS_SV_AGF}]

# Ici on cree des listes pour installer le driver un ou plusieurs noeud WAS
# A noter que l'ordre des items est important et ainsi a chaque noeud doit correspondre le bon fichier

set nodeInstalled [list fsdevelop2 fsmiami] 
set jdbcZipfileLocation [list /fsdevelop2/product/sybase/dev/12.0/jConnect-5_5/classes/jconn2.jar /fsmiami/product/sybase/rec/12.0/jConnect-5_2/classes/jconn2.jar ]

# Constitution des attributs
set DriverAttributelist [list $implClass $driverDescription]



#
# DATASOURCES
#

# Variables parametrables (exemple avec 2 datasources)

set dataSourceName [list FAODB_AGENCE FAODB_SECURITE]

set dbName [list {databaseName faodb_agence} {databaseName faodb_securite}]
set ServerName [list {serverName fsdevelop2} {serverName fsdevelop2}]
set SqlInitString [list {SQLINITSTRING use faodb_agence} {SQLINITSTRING use faodb_securite}]
set CharConv [list {CHARSET_CONVERTER_CLASS com.sybase.jdbc2.utils.TruncationConverter} {CHARSET_CONVERTER_CLASS com.sybase.jdbc2.utils.TruncationConverter}]
set dbUser [list {user pchupin} {user pchupin}]
set dbPasswd [list {password pascal02} {password pascal02}]
set PortNumber [list {portNumber 8540} {portnumber 8540}]
set jndiName [list {JNDIName jdbc/FAODB_AGENCE_LOCAL} {JNDIName jdbc/FAODB_SECURITE_LOCAL}]
set dsDescription [list {Description {DB FAO AGENCE}} {Description {DB FAO SECURITE}}]
set minPoolSize [list {MinPoolSize 1} {MinPoolSize 1}]
set maxPoolSize [list {MaxPoolSize 10} {MaxPoolSize 10}]
set connTimeout [list {ConnTimeout 180} {ConnTimeout 180}]
set idleTimeout [list {IdleTimeout 1800} {IdleTimeout 1800}]
set orphanTimeout [list {OrphanTimeout 1800} {OrphanTimeout 1800}]
set statementCacheSize [list {StatementCacheSize 100} {StatementCacheSize 100}]
set dynrep [list {DYNAMIC_PREPARE true} {DYNAMIC_PREPARE true}]
set repread [list {REPEAT_READ true} {REPEAT_READ true}]
set autoclean [list {DisableAutoConnectionCleanup False} {DisableAutoConnectionCleanup False}]


# Constitution des Attributs

set DSConfiglist [list]

for {set i 0} {$i < [llength $dataSourceName]} {incr i} {

   set tempconfig [list]

   for {set j 0} {$j < [llength $dataSourceName]} {incr j} {
      set templist [list [lindex $dbName $j] [lindex $ServerName $j] [lindex $PortNumber $j] [lindex $dbUser $j] [lindex $dbPasswd $j]]
      lappend tempconfig $templist
   }

   set templist [list ConfigProperties [lindex $tempconfig $i]]

   lappend DSConfiglist $templist
}

set DSattributelist [list]

for {set i 0} {$i < [llength $dataSourceName]} {incr i} {

   set templist [list [lindex $DSConfiglist $i] [lindex $jndiName $i] [lindex $dsDescription $i] [lindex $minPoolSize $i] [lindex $maxPoolSize $i] [lindex $connTimeout $i] [lindex $idleTimeout $i] [lindex $orphanTimeout $i] [lindex $statementCacheSize $i] [lindex $SqlInitString $i] [lindex $CharConv $i] [lindex $dynrep $i] [lindex $repread $i] [lindex $autoclean $i]]

   lappend DSattributelist $templist
}






# Message envoye a la fin 
puts "\nImportation du Fichier de Variables terminee\n"
