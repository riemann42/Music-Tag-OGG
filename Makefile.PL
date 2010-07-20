use ExtUtils::MakeMaker;
WriteMakefile( NAME         => "Music::Tag::OGG",
               VERSION_FROM => "lib/Music/Tag/OGG.pm",
               ABSTRACT_FROM => "lib/Music/Tag/OGG.pm",
               AUTHOR       => 'Edward Allen (ealleniii _at_ cpan _dot_ org)',
			   LICENSE		=> 'perl',
               PREREQ_PM => { 'MP3::Tag'				=> 0.29,
							  'Ogg::Vorbis::Header::PurePerl'		=> 0.07,
                            },
             );
