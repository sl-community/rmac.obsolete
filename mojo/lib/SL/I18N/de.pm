package SL::I18N::de;
use Mojo::Base 'SL::I18N';

our %Lexicon = (
    'From' => 'Von',
    'To'   => 'Bis',
    
    'Datafile extension' => 'Datenfile-Suffix',
    'Include DTD file'   => 'DTD-Datei mitliefern',
    'Long archive name'  => 'Langer Archivname',

    'Export successful' => 'Export erfolgreich',
    'Export failed'     => 'Export fehlgeschlagen',
    'Show log'          => 'Protokoll anzeigen',
    'Archive-Name'      => 'Archiv-Name',
    'Contents'          => 'Inhalt',

    # Buttons:
    'Continue'     => 'Weiter',
    'Back'         => 'Zurück',
    'Download ZIP' => 'ZIP herunterladen',
    'Download dump' => 'Dump herunterladen',
    'Back to database administration' => 'Zurück zur Datenbankverwaltung',
    'Main Menu' => 'Hauptmenü',
    
    # Errors:
    'Error' => 'Fehler',
    'Incorrect date format' => 'Falsches Datumsformat',
    'Database problem'  => 'Problem mit der Datenbank',
    'No filename specified' => 'Kein Dateiname angegeben',
    'Invalid filename' => 'Ungültiger Dateiname',

    # Testseite:
    'Testpage'              => 'Testseite',
    'type'                  => 'Typ',
    'Server time'           => 'Serverzeit',
    'Parameters'            => 'Parameter',
    'Configuration'         => 'Konfiguration',
    'Environment variables' => 'Umgebungsvariablen',
    "The filename must be in the form 'NAME(-|_)YYYY-MM-DD.sql.gz'" =>
        "Der Dateiname muß im Format 'NAME(-|_)YYYY-MM-DD.sql.gz' sein",
    'Invalid dataset name' => 'Ungültiger Datenset-Name',

    # Datenbank Backup/Restore:
    'Backup'  => 'Sichern',
    'Restore' => 'Wiederherstellen',
    'Dataset' => 'Datenset',
    'Size'    => 'Größe',
    'Action'  => 'Aktion',

    'Name of dataset to create (must not exist yet)' =>
        'Name des zu erstellenden Datensets (darf noch nicht existieren)',
    'Derive from filename' => 'Vom Dateinamen ableiten',
    'Use this name' => 'Diesen Namen verwenden',

    'No Datasets available' => 'Keine Datensets vorhanden',
    'can take a while'      => 'kann eine Weile dauern',
    'Restore successful'    => 'Wiederherstellung erfolgreich',
    'is now ready for use'  => 'kann jetzt genutzt werden',
);



1;
