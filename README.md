[![](https://img.shields.io/docker/cloud/build/ipbhalle/ccdbc.svg)](https://hub.docker.com/r/ipbhalle/ccdbc/builds/)

# CRIMSy Container Images

This project provides a collection of container images for use with [CRIMSy](https://github.com/ipb-halle/CRIMSy): 

 * An PostgreSQL image augmented with an extension for chemical structure handling (currently used: Bingo [https://github.com/epam/Indigo](https://github.com/epam/Indigo))
 * An Apache HTTP Server image containing a selection of JavaScript libraries for chemical drawing and spectra display

Additionally, this project provides Dockerfiles for experimenting with additional PostgreSQL releases and database extensions: ([RDKit](https://www.rdkit.org/docs/Cartridge.html) and [pgchem::tigress](https://github.com/ergo70/pgchem_tigress/))

# Getting started
To set up a fresh database container, usually the following sequence of commands is needed:

    cd crimsydb/$FLAVOUR
    docker build -t crimsydb:$FLAVOUR .
    docker run -e POSTGRES_PASSWORD="your-OWN-password" -v /path/to/your/storage:/var/lib/postgresql/data crimsydb:$FLAVOUR

`$FLAVOUR` currently can be one of `bingo_pg11, bingo_pg12, ccdbc_pg11` or `rdkit_pg13`. If you want to avoid building yourself, please use either `ipbhalle/crimsydb:bingo_pg12` or `ipbhalle/ccdbc` (outdated) from the docker registry.  For smaller experiments, you can omit `-v` option and store the data in your container.

A newly set up database requires activation of the database extensions. See the following example commands for reference:

    // Bingo
    /*
        GRANT USAGE ON SCHEMA bingo TO %ROLE%;
        GRANT SELECT ON bingo.bingo_config TO %ROLE%;
        GRANT SELECT ON bingo.bingo_tau_config TO %ROLE%;
     */
    CREATE TABLE example_bingo (
        id SERIAL NOT NULL PRIMARY KEY,
        mol TEXT);
    CREATE INDEX i_example_bingo_mol_idx ON example_bingo USING bingo_idx (mol bingo.molecule);
    SELECT * from example_bingo WHERE mol @ ('CCOCC', '')::bingo.sub;


    // pgchem::tigress
    CREATE EXTENSION IF NOT EXISTS "pgchem_tigress";
    CREATE TABLE example_pgchem (
        id SERIAL NOT NULL PRIMARY KEY,
        mol MOLECULE);
    CREATE INDEX i_example_pgchem_mol_idx ON example_pgchem USING gist(mol);
    SELECT * from example_pgchem WHERE mol >= 'CCOCC';

    // RDKit
    CREATE EXTENSION IF NOT EXISTS "rdkit";
    CREATE TABLE example_rdkit (
        id SERIAL NOT NULL PRIMARY KEY,
        mol MOL);
    CREATE INDEX i_example_rdkit_mol_idx ON example_rdkit USING gist(mol);
    SELECT * from example_rdkit WHERE mol @> 'CCOCC';

    
# More docs
The containers are based on the official Apache httpd and PostgreSQL containers, respectively. For reference see

 * Apache httpd: [https://hub.docker.com/_/httpd](https://hub.docker.com/_/httpd) and [https://github.com/docker-library/docs/blob/master/httpd/README.md](https://github.com/docker-library/docs/blob/master/httpd/README.md)
 * PostgreSQL:  [https://hub.docker.com/_/postgres](https://hub.docker.com/_/postgres) and [https://github.com/docker-library/docs/blob/master/postgres/README.md](https://github.com/docker-library/docs/blob/master/postgres/README.md)
 * Bingo: [https://github.com/epam/Indigo](https://github.com/epam/Indigo) and [https://lifescience.opensource.epam.com/bingo/user-manual-postgres.html](https://lifescience.opensource.epam.com/bingo/user-manual-postgres.html)
 * RDKit: [https://www.rdkit.org/docs/Cartridge.html](https://www.rdkit.org/docs/Cartridge.html) and [
 * pgchem::tigress: [https://github.com/ergo70/pgchem_tigress/](https://github.com/ergo70/pgchem_tigress/) Please note that pgchem::tigress builds on GPL licensed [OpenBabel](http://openbabel.org).

Have fun!

