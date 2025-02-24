require_relative "common"

namespace :docker do
  desc 'Run docker push'
  task :push do
    include DockerTaskCommon
    sh "docker", "login", "--username", docker_user, "--password", docker_password
    begin
      sh "docker", "push", image_name
      if ENV["TAG_LATEST"] == "true"
        image_name_with_new_tag = image_name("latest")
        sh "docker", "tag", image_name, image_name_with_new_tag
        sh "docker", "push", image_name_with_new_tag
      end
    ensure
      sh "docker", "logout"
    end
  end
end
