<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'moodledb';
$CFG->dbname    = 'moodle';
$CFG->dbuser    = 'root';
$CFG->dbpass    = 'root';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => 3306,
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_0900_ai_ci',
);

$CFG->wwwroot   = 'http://localhost:8071';
$CFG->dataroot  = '/var/moodledata';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

// enable debuging, show all error message
// @error_reporting(E_ALL | E_STRICT);
// @ini_set('display_errors', '1');
// $CFG->debug = (E_ALL | E_STRICT);
// $CFG->debugdisplay = 1;

// ignore the warning 
// @error_reporting(E_ALL & ~E_WARNING);
// @ini_set('display_errors', '1');
// $CFG->debug = (E_ALL & ~E_WARNING);
// $CFG->debugdisplay = 1;

// ignore the warning and Deprecated
@error_reporting(E_ALL & ~E_WARNING & ~E_DEPRECATED);
@ini_set('display_errors', '1');
$CFG->debug = (E_ALL & ~E_WARNING & ~E_DEPRECATED);
$CFG->debugdisplay = 1;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
