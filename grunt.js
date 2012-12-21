/*global module*/

module.exports = function (grunt) {
  'use strict';

  // Project configuration.
  grunt.initConfig({
    pkg: '<json:package.json>',

    // delete the dist folder
    delete: {
      reset: {
        files: ['./dist/']
      }
    },

    // lint CoffeeScript
    coffeeLint: {
      scripts: {
        src: './lib',
        indentation: {
          value: 2,
          level: 'error'
        },
        max_line_length: {
          level: 'ignore'
        },
        no_tabs: {
          level: 'ignore'
        }
      }
    },

    // compile CoffeeScript to JavaScript
    coffee: {
      bin: {
        src: './bin',
        dest: './dist/bin',
        bare: true
      },
      dist: {
        src: './lib',
        dest: './dist/lib',
        bare: true
      },
      test: {
        src: './test',
        dest: './dist/test',
        bare: true
      }
    },

    copy: {
      bin: {
        files: {
          './dist/bin/': './bin/'
        }
      }
    },

    test: {
      files: ['dist/test/**/*_test.js']
    },

    watch: {
      coffee: {
        files: './lib/**/*.coffee',
        tasks: 'coffeeLint coffee'
      },
      test: {
        files: './test/**/*.coffee',
        tasks: 'coffeeLint coffee'
      }
    },

    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        node: true
      },
      globals: {
        exports: true
      }
    }
  });

  grunt.loadNpmTasks('grunt-hustler');

  grunt.registerTask('default', [
    'delete',
    'coffeeLint',
    //'coffee:bin',
    'copy:bin',
    'coffee:dist',
    //'lint',
    'watch'
  ]);

  grunt.registerTask('test2', [
    'delete',
    'coffeeLint',
    'copy:bin',
    'coffee:dist',
    'coffee:test',
    'test'
  ]);

};