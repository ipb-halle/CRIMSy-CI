#!/usr/bin/perl -w
#
# Parse a SDFile and store the molecule records in  
# database table. Save the properties in a properties 
# table. The properties table is normalized and uses 
# property name IDs.
#
#
# Usage:
# sdfimport.pl [--bingo] [--pgchem] [--rdkit] FILE.sdf
# sdfimport.pl [--bingo] [--pgchem] [--rdkit] --init
#
use DBI;

$dbh = DBI->connect("dbi:Pg:dbname=test;host=localhost;port=5432", 
  'test', 'test', {AutoCommit => 1});

$PHASE_START=0;
$PHASE_CTAB=1;
$PHASE_CTAB_END=2;
$PHASE_PROPNAME=3;
$PHASE_PROPVAL=4;
$PHASE_END=5;

$phase = $PHASE_START;

$use_bingo = False;
$use_pgchem = False;
$use_rdkit = False;
$run_init = False;

@PROPNAMES = [];

for my $arg ( @ARGV ) {
    if ($arg eq "--init") {
        $run_init = True;
    } elsif ($arg eq "--bingo") {
        $use_bingo = True;
    } elsif ($arg eq "--pgchem") {
        $use_pgchem = True;
    } elsif ($arg eq "--rdkit") {
        $use_rdkit = True;
    } else {
        $filename = $arg;
    }
}

if (! ($use_bingo || $use_pgchem || $use_rdkit)) {
    die "You need to specify at least one of --bingo, --pgchem, --rdkit";
}

if ($run_init) {
	&initDB();
	exit(0);
}

open(IN, "zcat $filename |") or die "Could not open input file";

&loadPropnames();

while($l = <IN>)
{
	&testPhase($l);
	&processLine($l);
}
$dbh->disconnect();
close(IN);

#
#==========================================================
#
# process a single line of input according to current 
# parsing phase.
#
sub processLine() {
	my $ln = shift;

	if($phase == $PHASE_START) {
		$line = 1;
		undef %props;
		undef @molString;
		push @molString, $ln;
		$phase = $PHASE_CTAB;
		return;
	} elsif($phase == $PHASE_CTAB) {
		push @molString, $ln;
		$line++;
		#
		# if($line == 4) {
		#	we could do some validation of the counts line,
		#	but we'd need to take care of the V3000 format 
		#	as well!
		# }
		#
		return;
	} elsif($phase == $PHASE_CTAB_END) {
		push @molString, $ln;
		$phase = $PHASE_PROPNAME;
		return;
	} elsif($phase == $PHASE_PROPNAME) {
		if($ln =~ /^> <.+>$/){
			chomp $ln;
			$ln =~ s/^> <(.+)>$/$1/;
			$propname = $ln;
			$props{$propname} = ();
			$phase = $PHASE_PROPVAL;
		}
		return;
	} elsif($phase == $PHASE_PROPVAL) {
		push @{$props{$propname}}, $ln;
		return;
	} elsif($phase == $PHASE_END) {
		&saveMolecule;
		$phase = $PHASE_START;
		return;
	}
}
#
#==========================================================
#
# save a molecule and the accompanying property information
#
sub saveMolecule() {
        my $bingo_sql = "";
        my $pgchem_sql = "";
        my $rdkit_sql = "";
        my $sql_param = " ?, ?)";
        my $pgchem_id;
        my $rdkit_id;
	my $str = join "", @molString;
	my $sql;
	my $sep = "";
	my @bindValues;
        my @result;

	push @bindValues, $str;

        if ($use_bingo) {
            $sql = "INSERT INTO compounds_bingo(mol) VALUES (?) RETURNING id AS id";
            @result = $dbh->selectrow_arrayref($sql, undef, @bindValues);
            $bingo_id = $result[0]->[0];
            $bingo_sql = "bingo_id, ";
            $sql_param = "?, " . $sql_param;
        }

        if ($use_pgchem) {
            $sql = "INSERT INTO compounds_pgchem(mol) VALUES (?) RETURNING id AS id";
            @result = $dbh->selectrow_arrayref($sql, undef, @bindValues);
            $pgchem_id = $result[0]->[0]; 
            $pgchem_sql = "pgchem_id, ";
            $sql_param = "?, " . $sql_param;
        }

        if ($use_rdkit) {
            $sql = "INSERT INTO compounds_rdkit(mol) VALUES (mol_from_ctab(?)) RETURNING id AS id";
            @result = $dbh->selectrow_arrayref($sql, undef, @bindValues);
            $rdkit_id = $result[0]->[0];
            $rdkit_sql = "rdkit_id, ";
            $sql_param = "?, " . $sql_param;
        }

	pop @bindValues;

	$sql = "INSERT INTO compound_properties($bingo_sql $pgchem_sql $rdkit_sql, propId, propVal) VALUES ";
        $sql_param = "(" . $sql_param;

	for my $i (keys %props) {
		my $a = $props{$i};
		pop @{$a};
		$str = join "", @{$a};
		chomp $str;

		# $bindValues[0] = $pgchem_id;
                # $bindValues[1] = $rdkit_id;
		# $bindValues[2] = &getPropname($i);
		# $bindValues[3] = $str;
		# printf("id=%d prop=%s val=\n%s\n", $id, $i, $str);
		# $sql = "INSERT INTO compound_properties(id, propId, propVal) VALUES (?,?,?)";

                if ($use_bingo) {
                    push @bindValues, $bingo_id;
                }

                if ($use_pgchem) {
    		    push @bindValues, $pgchem_id;
                }

                if ($use_rdkit) {
                    push @bindValues, $rdkit_id;
                }

		push @bindValues, &getPropname($i);
		push @bindValues, $str;
		$sql .= $sep . $sql_param;
		$sep = ", ";
	}
	if($sep eq ", ") {
		$dbh->do($sql, undef, @bindValues);
	}

	if(($pgchem_id % 1000) == 0) {
		printf "ID: %d\n", $pgchem_id;
	}
}

#
#==========================================================
#
# Get the id of a property, either from the %PROPNAMES
# hash or by inserting new propnames into the propNames 
# table in the database.
#
sub getPropname() {
	my $pn = shift;

	if(defined $PROPNAMES{$pn}) {
		return $PROPNAMES{$pn};
	} 

	my $sql = "INSERT INTO propertyNames (propname) VALUES (?) RETURNING id AS id";
	my @bindValues;

	
       	push @bindValues, $pn;

	my @result = $dbh->selectrow_arrayref($sql, undef, @bindValues);
	my $id = $result[0]->[0];
	$PROPNAMES{$pn} = $id;
	return $id;
}
#
#==========================================================
#
# Initialize the database. Drops tables prior to creating them.
#
sub initDB() {
        my $bingo_ref = "";
        my $pgchem_ref = "";
        my $rdkit_ref = "";

	$dbh->do("DROP TABLE IF EXISTS compound_properties");
	$dbh->do("DROP TABLE IF EXISTS propertyNames");

        if ($use_bingo) {
            $bingo_ref = &initBINGO();
        }
        if ($use_pgchem) {
            $pgchem_ref = &initPGCHEM();
        }
        if ($use_rdkit) {
            $rdkit_ref = &initRDKIT();
        }

	$dbh->do("CREATE TABLE propertyNames ( id SERIAL NOT NULL PRIMARY KEY, 
	  propname VARCHAR NOT NULL, UNIQUE(propname))");

	$dbh->do("CREATE TABLE compound_properties (
          id BIGSERIAL NOT NULL PRIMARY KEY,
          $bingo_ref
          $pgchem_ref
          $rdkit_ref
	  propId INTEGER NOT NULL REFERENCES propertyNames(id) ON DELETE CASCADE,
	  propVal VARCHAR)");

	$dbh->do("CREATE INDEX compound_properties_id_idx ON compound_properties (id)");
	$dbh->do("CREATE INDEX compound_properties_propval_idx ON compound_properties (propval)");

}

sub initBINGO() {
        $dbh->do("DROP TABLE IF EXISTS compounds_bingo");
        $dbh->do("CREATE TABLE compounds_pgchem (id SERIAL NOT NULL PRIMARY KEY,
          mol TEXT)");
        $dbh->do("CREATE INDEX i_compounds_bingo_mol ON compounds_bingo USING bingo_idx (mol bingo.molecule)");
        return "bingo_id BIGINT NOT NULL REFERENCES compounds_bingo(id) ON DELETE CASCADE,";
}

sub initPGCHEM() {
        $dbh->do("DROP TABLE IF EXISTS compounds_pgchem");
        $dbh->do("CREATE TABLE compounds_pgchem (id SERIAL NOT NULL PRIMARY KEY,
          mol MOLECULE)");
        $dbh->do("CREATE INDEX i_compounds_pgchem_mol ON compounds_pgchem USING GIST(mol)");
        return "pgchem_id BIGINT NOT NULL REFERENCES compounds_pgchem(id) ON DELETE CASCADE,";
}

sub initRDKIT() {
        $dbh->do("DROP TABLE IF EXISTS compounds_rdkit");
        $dbh->do("CREATE TABLE compounds_rdkit (id SERIAL NOT NULL PRIMARY KEY,
          mol mol)");
        $dbh->do("CREATE INDEX i_compounds_rdkit ON compounds_rdkit USING GIST(mol)");
        return "rdkit_id BIGINT NOT NULL REFERENCES compounds_rdkit(id) ON DELETE CASCADE,";
}
#
#==========================================================
#
# Load the property names into the PROPNAMES hash
#
sub loadPropnames() {
	my $sql = "SELECT id, propname FROM propertyNames";
	my $result = $dbh->selectall_arrayref($sql);
	my $cnt = 0;

	for $record ( @{$result} ) {
		$PROPNAMES{$record->[1]} = $record->[0];
		$cnt++;
	}
	print "loaded propname cache with $cnt entries.\n";
}

#
#==========================================================
#
# Check whether the phase of SDF parsing has to 
# be changed.
#
sub testPhase() {
	my $ln = shift;

	if($ln =~ /^\$\$\$\$$/) {
		$phase = $PHASE_END;
		return;
	}

	if($ln =~ /^> <.+>$/) {
		$phase = $PHASE_PROPNAME;
		return;
	}

	if($ln =~ /^M  END$/) {
		$phase = $PHASE_CTAB_END;
		return;
	}
}

