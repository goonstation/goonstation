// Generated on 2015-07-28 using
// generator-webapp 1.0.1
'use strict';

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// If you want to recursively match all subfolders, use:
// 'test/spec/**/*.js'

module.exports = function (grunt) {

  // Time how long tasks take. Can help when optimizing build times
  require('time-grunt')(grunt);

  // Automatically load required grunt tasks
  require('jit-grunt')(grunt);

	var os = require('os');

  // Configurable paths
  var config = {
    app: '.',
    dist: 'build'
  };

  var rev = grunt.file.read('revision') || '1';
  rev = rev.replace(/(\r\n|\n|\r)/gm, '');
	var serverType = grunt.option('servertype') || '';
	if (serverType === 'main') serverType = '';
  var cdn = 'https://cdn'+serverType+'.goonhub.com';

  // Define the configuration for all the tasks
  grunt.initConfig({

    // Project settings
    config: config,

    // Empties folders to start fresh
    clean: {
      dist: {
        files: [{
          dot: true,
          src: [
            '.tmp',
            '<%= config.dist %>/*',
            '!<%= config.dist %>/.git*'
          ]
        }]
      }
    },

    // Make sure code styles are up to par and there are no obvious mistakes
    eslint: {
      target: [
        'Gruntfile.js',
        '<%= config.app %>/js/{,*/}*.js',
      ]
    },

    // Compiles Sass to CSS and generates necessary files if requested
    sass: {
      options: {
        sourceMap: false,
        includePaths: ['.']
      },
      dist: {
        files: [{
          expand: true,
          cwd: '<%= config.dist %>/css',
          src: '**/*.{scss,sass}',
          dest: '<%= config.dist %>/css',
          ext: '.css'
        }]
      }
    },

    postcss: {
      options: {
        map: false,
        processors: [
          require('autoprefixer-core')({browsers: 'ie >= 7'}),
          require('cssnano')()
        ]
      },
      dist: {
        files: [{
          expand: true,
          cwd: '<%= config.dist %>/css',
          src: '**/*.css',
          dest: '<%= config.dist %>/css'
        }]
      }
    },

    // The following *-min tasks produce minified files in the dist folder
    imagemin: {
      dist: {
        options: {
          concurrency: Math.max(1, Math.round(os.cpus().length / 2))
        },
        files: [{
          expand: true,
          cwd: '<%= config.app %>/images',
          src: '**/*.{gif,jpeg,jpg,png}',
          dest: '<%= config.dist %>/images'
        }]
      }
    },

    svgmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= config.app %>/images',
          src: '**/*.svg',
          dest: '<%= config.dist %>/images'
        }]
      }
    },

    'string-replace': {
      html: {
        files: [{
          expand: true,
          cwd: '<%= config.app %>/html',
          src: '**/*.{html,htm}',
          dest: '<%= config.dist %>/html'
        }],
        options: {
          replacements: [{
            pattern: /\{\{resource\(\"(.*?)\"\)\}\}/ig,
            replacement: cdn + '/$1' + '?v=' + rev
            //replacement: cdn + '/$1'
          }]
        }
      },
      css: {
        files: [{
          expand: true,
          cwd: '<%= config.app %>/css',
          src: '**/*.{scss,sass,css}',
          dest: '<%= config.dist %>/css'
        }],
        options: {
          replacements: [{
            pattern: /\{\{resource\(\"(.*?)\"\)\}\}/ig,
            replacement: cdn + '/$1' + '?v=' + rev
            //replacement: cdn + '/$1'
          }]
        }
      },
      js: {
        files: [{
          expand: true,
          cwd: '<%= config.app %>/js',
          src: '**/*.js',
          dest: '<%= config.dist %>/js'
        }],
        options: {
          replacements: [{
            pattern: /\{\{resource\(\"(.*?)\"\)\}\}/ig,
            replacement: cdn + '/$1' + '?v=' + rev
            //replacement: cdn + '/$1'
          }]
        }
      }
    },

    htmlmin: {
      dist: {
        options: {
          collapseBooleanAttributes: true,
          collapseWhitespace: true,
          conservativeCollapse: true,
          removeComments: false,
          removeAttributeQuotes: true,
          removeCommentsFromCDATA: true,
          removeEmptyAttributes: true,
          removeOptionalTags: false,
          // true would impact styles with attribute selectors
          removeRedundantAttributes: false,
          useShortDoctype: true
        },
        files: [{
          expand: true,
          cwd: '<%= config.dist %>/html',
          src: '**/*.html',
          dest: '<%= config.dist %>/html'
        }]
      }
    },

    uglify: {
      options: {
        mangle: true,
        compress: true,
        preserveComments: 'all'
      },
      dist: {
        files: [{
          expand: true,
          cwd: '<%= config.dist %>/js',
          src: '**/*.js',
          dest: '<%= config.dist %>/js'
        }]
      }
    },

    // Copies remaining files to places other tasks can use
    copy: {
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= config.app %>',
          dest: '<%= config.dist %>',
          src: [
            'images/{,*/}*.webp',
            'css/fonts/**',
						'sounds/**',
						'misc/**',
						'tgui/**'
          ]
        },
        ]
      },
      temp: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= config.app %>',
          dest: '<%= config.dist %>',
          src: [
            'css/**/*',
            'html/**/*'
          ]
        },
        ]

      }
    },

    // Run some tasks in parallel to speed up build process
    concurrent: {
      dist: [
        'sass',
        'imagemin',
        'svgmin'
      ]
    }
  });

  grunt.registerTask('build', [
    'clean',
    'copy:temp',
    //'string-replace:css',
    'concurrent:dist',
    'postcss',
    'uglify',
    'copy:dist',
    //'string-replace:html',
    'htmlmin'
  ]);

  grunt.registerTask('build-cdn', [
    'clean',
    'string-replace:css',
    //'sass',
    'imagemin',
    'svgmin',
    'postcss',
    'string-replace:js',
    'uglify',
    'string-replace:html',
    'htmlmin',
    'copy:dist'
  ]);

  grunt.registerTask('build-byond', [
    'clean',
    'string-replace:html',
    'htmlmin'
  ]);

  grunt.registerTask('default', [
    'build'
  ]);
};
