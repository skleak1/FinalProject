pipeline {
    agent any

    stages {
        stage('Check Branch') {
            when {
                branch 'main'
            }
            steps {
                echo "Running on main branch"
            }
        }

        stage('Build') {
            when {
                branch 'main'
            }
            steps {
                echo 'Building...'
            }
        }
    }
}
