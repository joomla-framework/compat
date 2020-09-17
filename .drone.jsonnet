local volumes = [
    {
        name: "composer-cache",
        path: "/tmp/composer-cache",
    },
];

local hostvolumes = [
    {
        name: "composer-cache",
        host: {path: "/tmp/composer-cache"}
    },
];

[
    {
        kind: "pipeline",
        name: "Codequality",
        volumes: hostvolumes,
        steps: [
            {
                name: "composer",
                image: "joomlaprojects/docker-images:php7.4",
                volumes: volumes,
                commands: [
                    "php -v",
                    "composer update",
                    "composer require phpmd/phpmd phpstan/phpstan"
                ]
            },
            {
                name: "phpcs",
                image: "joomlaprojects/docker-images:php7.4",
                depends: [ "composer" ],
                commands: [
                    "vendor/bin/phpcs --config-set installed_paths vendor/joomla/coding-standards",
                    "vendor/bin/phpcs -p --report=full --extensions=php --standard=Joomla src/"
                ]
            },
            {
                name: "phpmd",
                image: "joomlaprojects/docker-images:php7.4",
                depends: [ "composer" ],
                failure: "ignore",
                commands: [
                    "vendor/bin/phpmd src text cleancode",
                    "vendor/bin/phpmd src text codesize",
                    "vendor/bin/phpmd src text controversial",
                    "vendor/bin/phpmd src text design",
                    "vendor/bin/phpmd src text unusedcode",
                ]
            },
            {
                name: "phpstan",
                image: "joomlaprojects/docker-images:php7.4",
                depends: [ "composer" ],
                failure: "ignore",
                commands: [
                    "vendor/bin/phpstan analyse src",
                ]
            },
            {
                name: "phploc",
                image: "joomlaprojects/docker-images:php7.4",
                depends: [ "composer" ],
                failure: "ignore",
                commands: [
                    "phploc src",
                ]
            },
            {
                name: "phpcpd",
                image: "joomlaprojects/docker-images:php7.4",
                depends: [ "composer" ],
                failure: "ignore",
                commands: [
                    "phpcpd src",
                ]
            }
        ]
    }
]
