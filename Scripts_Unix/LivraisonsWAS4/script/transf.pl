#!/usr/bin/perl
#


use Getopt::Long;


#Parser la ligne de commande et récupérer les noms des fichiers ini des clones
my @filesclones = ();
GetOptions (
	"clone=s" => \@filesclones,
	"dest=s" => \$destination,
	"ini=s" => \$inifile,
	"generic=s" => \$genericfile,
	"genericlone=s" => \$genericlone
);

#Purger le fichier tcl de destination

#$file = '/tmp/travail/ao/ao_was.tcl';
open (INFO, ">$destination");
close (INFO);



#Ouvrir le fichier ini correspondant aux variables was de l'application
#$file = '/tmp/travail/ao/ao_was.ini';
open(INFO, $inifile);              # Open the file
@lines = <INFO>;                # Read it into an array
close(INFO);                    # Close the file

#Transformer le ini en tcl
foreach $line (@lines)
{
        $line =~ s/^([^#]\S*) (.*)/set \1 \[list \2\]/;
        $line =~ s/\,/ /g;
}

#Ouvrir le fichier générique tcl de contenant les variables was
#$file = '/tmp/travail/ao/invariant/was.tcl';
open (INFO, $genericfile);
@lines_was = <INFO>;
close(INFO);


#Transformer tous les fichiers ini des clones
for ($i=0; $i <= $#filesclones; $i++) 
{
	$j=$i+1;
#Ouvrir un par un les fichiers ini correspondant aux clones		
	open (INFO, $filesclones[$i]);
	@lines_clone = <INFO>;
	close (INFO);
	print "$filesclones[$i]\n";

#Transformer le fichier ini en tcl
	foreach $line_clone (@lines_clone)
	{
        	$line_clone =~ s/^([^#]\S*) (.*)/set clone\(\1$j\) \[list \2\]/;
        	$line_clone =~ s/\,/ /g;
	}

#Charger le fichier tcl dynamique correspondant aux clones
#	$file = '/tmp/travail/ao/invariant/clones.tcl';
	open (INFO, $genericlone);
	@lines_clones = <INFO>;
	close(INFO);

#Transformer le fichier tcl dynamique correspondant aux clones
	foreach $line_clones (@lines_clones)
	{
        	$line_clones =~ s/_ccc_/$j/g;
	}
	
#	$file = '/tmp/travail/ao/ao_was.tcl';
	open (INFO, ">>$destination");
	print INFO @lines_clone;
	print INFO @lines_clones;
	close (INFO);
}

$ligne_nbclones = "set NumberOfClones $j\n";

#$file = '/tmp/travail/ao/ao_was.tcl';
open (INFO, ">>$destination");
print INFO $ligne_nbclones;
print INFO @lines;
print INFO @lines_was;
close (INFO);
