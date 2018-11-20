class VisitorsController < ApplicationController
  
  layout 'project_layout'
   require 'net/http'
   require 'uri'
   require 'json'
   require 'openssl'
  TOKEN = "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJwZGZseSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkZWZhdWx0LXRva2VuLWRxbWtiIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImRlZmF1bHQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIwMjg1Njg0Mi1jNzA0LTExZTgtYTIxZC0wYTFmOTU2MjNjZGEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6cGRmbHk6ZGVmYXVsdCJ9.dW4JyKe6T7xH34M0rRb3VhORXpGZ7DQ_5rPREZiut7DPjAeQT_LK8cemgtQsXNwqc80B429xBz4HLsT30qLR6xWHblVCNclM3m6sXIHex40Nt9NHYjB7wdtcuqBRAmrHry9fHlkdG0rf-8uYcBeBeHAqpTORircLJwL_F2lbzf9sSfg6P_A19-Z5PptYHZtuHq4WBYswvW7fVBjCKrHDOTz6mmyz-uiSnvVMZcYF5KBWctEsdWck4hZ3OITkk2vw1mYBkz0WCUD0kSpkRnBl18yx3nHeXrJnjfWCwF_nnnC2HtM6kZ4inmOG-uHBeUPLIYCtGuAZ1zy0GYQjjZTwpA"
    
  def index
    @user = current_user
    @project = @user.project
  end

  def new
    if current_user && current_user.project.present?
      redirect_to visitors_path
    else
      @project = Project.new
    end
  end

  def create
    @project = Project.new
    @visitor = current_user.build_project(secure_params)
    pvc_availble = PvContainer.where(pv_used: 0).first
    proj_name =  @visitor.try(:project_name)
    if @visitor.save
     #  p "=============#{proj_name} ===== project"
     #  p "================ #{TOKEN} =======token======"
     #  new_project_app(proj_name)
     #  project_policy_binding(proj_name, current_user.try(:lanid))
     #  git_url = git_repo_build(proj_name)
     #  @visitor.git_repo_url = git_url
     #  @visitor.save
     #  #test_pvc(proj_name, pvc_availble)
     # # pvc_build_container(proj_name,pvc_availble)
     #  #pvc_availble.pv_used = 1
     #  #pvc_availble.project_name = @visitor.try(:project_name)
     #  #pvc_availble.save
     #  params["project"]["db_name"] == "Mysql" ? mysql_build_container(proj_name,pvc_availble) : postgres_build_container(proj_name,pvc_availble)
     #  svc_build_container(proj_name)
       flash[:notice] = "project created successful"
       redirect_to visitors_path 
    else
      render :new
    end
  end

  def test_pvc(project_name, pv)
    p "======================#{pv.inspect}  ========= pvvvvv"
    p "=======================#{project_name} ------- project----"
  end

  def new_project_app(project_name)
    uri = URI.parse("https://ose.cpaas.service.test:8443/oapi/v1/projectrequests")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Accept"] = "application/json"
request["Authorization"] = TOKEN
request.body = JSON.dump({
  "kind" => "ProjectRequest",
  "apiVersion" => "v1",
  "metadata" => {
    "name" => project_name,
    "creationTimestamp" => nil
  }
})

req_options = {
  use_ssl: uri.scheme == "https",
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end
  end




  def project_policy_binding(project_name,lanid)
    uri = URI.parse("https://ose.cpaas.service.test:8443/oapi/v1/namespaces/"+project_name+"/rolebindings/admin")
    request = Net::HTTP::Put.new(uri)
    request.content_type = "application/json"
    request["Accept"] = "application/json"
    request["Authorization"] = TOKEN
    request.body = JSON.dump({
  "kind" => "RoleBinding",
  "apiVersion" => "v1",
  "metadata" => {
    "name" => "admin",
    "namespace" => project_name
  },
  "userNames" => [
    "system:serviceaccount:"+project_name+":default",
    lanid
  ],
  "groupNames" => nil,
  "subjects" => [
    {
      "kind" => "ServiceAccount",
      "namespace" => project_name,
      "name" => "default"
    },
    {
      "kind" => "User",
      "name" => lanid
    }
  ],
  "roleRef" => {
    "name" => "admin"
  }
})

   req_options = {
     use_ssl: uri.scheme == "https",
     verify_mode: OpenSSL::SSL::VERIFY_NONE,
   }

   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
     http.request(request)
   end

  end

  def git_repo_build(project_name)
  
    uri = URI.parse("http://gogs-pdgogs.apps.abd6.example.opentlc.com/api/v1/user/repos?token=f980f81060bb671692020cc54c4995e6a0a1a767")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/x-www-form-urlencoded"
    request["Accept"] = "application/json"
    request.set_form_data(
      "name" => project_name+"_repo",
    )

   req_options = {
     use_ssl: uri.scheme == "https",
     verify_mode: OpenSSL::SSL::VERIFY_NONE,
   }

   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
   end
   data = JSON.parse(response.body)["clone_url"]
   return data
  end

  def pvc_build_container(project_name,pv)
   uri = URI.parse("https://ose.cpaas.service.test:8443/api/v1/namespaces/"+project_name+"/persistentvolumeclaims")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Authorization"] = TOKEN
request["Accept"] = "application/json"
request.body = JSON.dump({
  "kind" => "PersistentVolumeClaim",
  "apiVersion" => "v1",
  "metadata" => {
    "name" => pv.present? ? pv.pv_name+"-pvc" : nil,
    "namespace" => project_name,
    "creationTimestamp" => nil
  },
  "spec" => {
    "accessModes" => [
      "ReadWriteOnce"
    ],
    "resources" => {
      "requests" => {
        "storage" => "50Gi"
      }
    },
    "volumeName" => pv.present? ? pv.pv_name : nil
  }
})

req_options = {
  use_ssl: uri.scheme == "https",
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end
  end

  def mysql_build_container(project_name,pv)
   uri = URI.parse("https://ose.cpaas.service.test:8443/oapi/v1/namespaces/"+project_name+"/deploymentconfigs")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Authorization"] = TOKEN
request["Accept"] = "application/json"
request.body = JSON.dump({
  "apiVersion" => "v1",
  "kind" => "DeploymentConfig",
  "metadata" => {
    "creationTimestamp" => nil,
    "generation" => 1,
    "labels" => {
      "app" => "mysql"
    },
    "name" => "mysql",
    "namespace" => project_name
  },
  "spec" => {
    "replicas" => 1,
    "selector" => {
      "app" => "mysql",
      "deploymentconfig" => "mysql"
    },
    "strategy" => {
      "activeDeadlineSeconds" => 21600,
      "rollingParams" => {
        "intervalSeconds" => 1,
        "maxSurge" => "25%",
        "maxUnavailable" => "25%",
        "timeoutSeconds" => 600,
        "updatePeriodSeconds" => 1
      },
      "type" => "Rolling"
    },
    "template" => {
      "metadata" => {
        "annotations" => {
          "openshift.io/generated-by" => "OpenShiftNewApp"
        },
        "creationTimestamp" => nil,
        "labels" => {
          "app" => "mysql",
          "deploymentconfig" => "mysql"
        }
      },
      "spec" => {
        "containers" => [
          {
            "env" => [
              {
                "name" => "MYSQL_ROOT_PASSWORD",
                "value" => "password"
              }
            ],
            "image" => "registry.access.redhat.com/rhscl/mysql-57-rhel7",
            "imagePullPolicy" => "Always",
            "name" => "mysql",
            "ports" => [
              {
                "containerPort" => 3306,
                "protocol" => "TCP"
              }
            ],
            "terminationMessagePath" => "/dev/termination-log",
            "terminationMessagePolicy" => "File",
            "volumeMounts" => [
              {
                "mountPath" => "/var/lib/mysql/data",
                "name" => "mysql-data"
              }
            ]
          }
        ],
        "dnsPolicy" => "ClusterFirst",
        "restartPolicy" => "Always",
        "schedulerName" => "default-scheduler",
        "terminationGracePeriodSeconds" => 30,
        "volumes" => [
          {
            "name" => "mysql-data"
          }
        ]
      }
    },
    "test" => false
  }
})

req_options = {
  use_ssl: uri.scheme == "https",
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end
  end



def postgres_build_container(project_name,pv)
   uri = URI.parse("https://ose.cpaas.service.test:8443/oapi/v1/namespaces/"+project_name+"/deploymentconfigs")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Authorization"] = TOKEN
request["Accept"] = "application/json"
request.body = JSON.dump({
  "apiVersion": "v1",
  "kind": "DeploymentConfig",
  "metadata": {
    "creationTimestamp": null,
    "generation": 1,

      "labels": {

         "app": "postgresql"

      },

      "name": "postgresql",
      "namespace" => project_name

   },

   "spec": {

      "replicas": 1,

      "revisionHistoryLimit": 10,

      "selector": {

         "app": "postgresql",

         "deploymentconfig": "postgresql"

      },

      "strategy": {

         "activeDeadlineSeconds": 21600,

         "resources": {},

         "rollingParams": {

            "intervalSeconds": 1,

            "maxSurge": "25%",

            "maxUnavailable": "25%",

            "timeoutSeconds": 600,

            "updatePeriodSeconds": 1

         },

         "type": "Rolling"

      },

      "template": {

         "metadata": {

            "annotations": {

               "openshift.io/generated-by": "OpenShiftNewApp"

            },

            "creationTimestamp": null,

            "labels": {

               "app": "postgresql",

               "deploymentconfig": "postgresql"

            }

         },

         "spec": {

            "containers": [

               {

                  "env": [

                     {

                        "name": "POSTGRESQL_DATABASE",

                        "value": "gogs"

                     },

                     {

                        "name": "POSTGRESQL_PASSWORD",

                        "value": "root"

                     },

                     {

                        "name": "POSTGRESQL_USER",

                        "value": "root"

                     }

                  ],

                  "image": "dcartifactory.service.dev:5000/openshift3/postgresql-94-rhel7@sha256:c18718bbbd0c94827d9c6ecea41d9515755b6470f15969ce8a633d161f848ece",

                  "imagePullPolicy": "Always",

                  "name": "postgresql",

                  "ports": [

                     {

                        "containerPort": 5432,

                        "protocol": "TCP"

                     }

                  ],

                  "resources": {},

                  "terminationMessagePath": "/dev/termination-log",

                  "terminationMessagePolicy": "File",

                  "volumeMounts": [

                     {

                        "mountPath": "/var/lib/pgsql/data",

                        "name": "postgresql"

                     }

                  ]

               }

            ],

            "dnsPolicy": "ClusterFirst",

            "restartPolicy": "Always",

            "schedulerName": "default-scheduler",

            "securityContext": {},

            "terminationGracePeriodSeconds": 30,

            "volumes": [

               {

                  "emptyDir": {},

                  "name": "postgresql"

               }

            ]

         }

      },

      "test": false

   }

})

  req_options = {
    use_ssl: uri.scheme == "https",
    verify_mode: OpenSSL::SSL::VERIFY_NONE,
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
end











  def svc_build_container(project_name)
   uri = URI.parse("https://ose.cpaas.service.test:8443/api/v1/namespaces/"+project_name+"/services")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Authorization"] = TOKEN
request["Accept"] = "application/json"
request.body = JSON.dump({
  "apiVersion" => "v1",
  "kind" => "Service",
  "metadata" => {
    "creationTimestamp" => nil,
    "name" => "mysql",
    "namespace" => project_name
  },
  "spec" => {
    "ports" => [
      {
        "name" => "3306-tcp",
        "port" => 3306,
        "protocol" => "TCP",
        "targetPort" => 3306
      }
    ],
    "sessionAffinity" => "None",
    "type" => "ClusterIP"
  }
})

req_options = {
  use_ssl: uri.scheme == "https",
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end
  end

  def destroy
    project = Project.find_by_id(params[:id])
    uri = URI.parse("https://ose.cpaas.service.test:8443/oapi/v1/projects/"+project.try(:project_name))
request = Net::HTTP::Delete.new(uri)
request.content_type = "application/json"
request["Authorization"] = TOKEN
request["Accept"] = "application/json"
request.body = JSON.dump({
  "orphanDependents" => false
})

req_options = {
  use_ssl: uri.scheme == "https",
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end
  project.destroy
  #pv_update = PvContainer.where(project_name: project.project_name).first
  #pv_update.pv_used = 0
  #pv_update.save
  redirect_to new_visitor_path
  end


  def new_build
   uri = URI.parse("https://ose.cpaas.service.test:8443/oapi/v1/namespaces/"+params[:project_name]+"/imagestreamimports")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Accept"] = "application/json"
request["Authorization"] = TOKEN
request.body = JSON.dump({
  "kind" => "ImageStreamImport",
  "apiVersion" => "v1",
  "metadata" => {
    "name" => "newapp",
    "creationTimestamp" => nil
  },
  "spec" => {
    "import" => false,
    "images" => [
      {
        "from" => {
          "kind" => "DockerImage",
          "name" => "172.30.200.79:5000/openshift/nodejs-4-rhel7:latest"
        },
        "importPolicy" => {
          "insecure" => true
        }
      }
    ]
  }
})

req_options = {
  use_ssl: uri.scheme == "https",
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end
   
uri = URI.parse("https://ose.cpaas.service.test:8443/apis/image.openshift.io/v1/namespaces/"+params[:project_name]+"/imagestreams")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Authorization"] = TOKEN
request["Accept"] = "application/json,"
request.body = JSON.dump({
  "kind" => "ImageStream",
  "apiVersion" => "image.openshift.io/v1",
  "metadata" => {
    "name" => "nodejs-4-rhel7",
    "creationTimestamp" => nil,
    "labels" => {
      "app" => "node"
    },
    "annotations" => {
      "openshift.io/generated-by" => "OpenShiftNewApp"
    }
  },
  "spec" => {
    "lookupPolicy" => {
      "local" => false
    },
    "tags" => [
      {
        "name" => "latest",
        "annotations" => {
          "openshift.io/imported-from" => "172.30.200.79:5000/openshift/nodejs-4-rhel7:latest"
        },
        "from" => {
          "kind" => "DockerImage",
          "name" => "172.30.200.79:5000/openshift/nodejs-4-rhel7:latest"
        },
        "generation" => nil,
        "importPolicy" => {
          "insecure" => true
        }
      }
    ]
  }
})

req_options = {
  use_ssl: uri.scheme == "https",
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end


   uri = URI.parse("https://ose.cpaas.service.test:8443/apis/image.openshift.io/v1/namespaces/"+params[:project_name]+"/imagestreams")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Authorization"] = TOKEN
request["Accept"] = "application/json,"
request.body = JSON.dump({
  "kind" => "ImageStream",
  "apiVersion" => "image.openshift.io/v1",
  "metadata" => {
    "name" => "node",
    "creationTimestamp" => nil,
    "labels" => {
      "app" => "node"
    },
    "annotations" => {
      "openshift.io/generated-by" => "OpenShiftNewApp"
    }
  },
  "spec" => {
    "lookupPolicy" => {
      "local" => false
    }
  }
})

req_options = {
  use_ssl: uri.scheme == "https",
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end



uri = URI.parse("https://ose.cpaas.service.test:8443/apis/build.openshift.io/v1/namespaces/"+params[:project_name]+"/buildconfigs")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Accept"] = "application/json,"
request["Authorization"] = TOKEN
request.body = JSON.dump({
  "kind" => "BuildConfig",
  "apiVersion" => "build.openshift.io/v1",
  "metadata" => {
    "name" => "node",
    "creationTimestamp" => nil,
    "labels" => {
      "app" => "node"
    },
    "annotations" => {
      "openshift.io/generated-by" => "OpenShiftNewApp"
    }
  },
  "spec" => {
    "triggers" => [
      {
        "type" => "GitHub",
        "github" => {
          "secret" => "g43U8Hu5hRkVUTVYQjWr"
        }
      },
      {
        "type" => "Generic",
        "generic" => {
          "secret" => "jekb8UAKPC56VZBnLSrt"
        }
      },
      {
        "type" => "ConfigChange"
      },
      {
        "type" => "ImageChange"
      }
    ],
    "source" => {
      "type" => "Git",
      "git" => {
        "uri" => "http://gogs.apps.cpaas.service.test/pocfly/Nodejs.git"
      }
    },
    "strategy" => {
      "type" => "Source",
      "sourceStrategy" => {
        "from" => {
          "kind" => "ImageStreamTag",
          "name" => "nodejs-4-rhel7:latest"
        }
      }
    },
    "output" => {
      "to" => {
        "kind" => "ImageStreamTag",
        "name" => "node:latest"
      }
    },
    "nodeSelector" => nil
  },
  "status" => {
    "lastVersion" => 0
  }
})

req_options = {
  use_ssl: uri.scheme == "https",
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end


uri = URI.parse("https://ose.cpaas.service.test:8443/apis/apps.openshift.io/v1/namespaces/"+params[:project_name]+"/deploymentconfigs")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Accept"] = "application/json,"
request["Authorization"] = TOKEN
request.body = JSON.dump({
  "kind" => "DeploymentConfig",
  "apiVersion" => "apps.openshift.io/v1",
  "metadata" => {
    "name" => "node",
    "creationTimestamp" => nil,
    "labels" => {
      "app" => "node"
    },
    "annotations" => {
      "openshift.io/generated-by" => "OpenShiftNewApp"
    }
  },
  "spec" => {
    "triggers" => [
      {
        "type" => "ConfigChange"
      },
      {
        "type" => "ImageChange",
        "imageChangeParams" => {
          "automatic" => true,
          "containerNames" => [
            "node"
          ],
          "from" => {
            "kind" => "ImageStreamTag",
            "name" => "node:latest"
          }
        }
      }
    ],
    "replicas" => 1,
    "test" => false,
    "selector" => {
      "app" => "node",
      "deploymentconfig" => "node"
    },
    "template" => {
      "metadata" => {
        "creationTimestamp" => nil,
        "labels" => {
          "app" => "node",
          "deploymentconfig" => "node"
        },
        "annotations" => {
          "openshift.io/generated-by" => "OpenShiftNewApp"
        }
      },
      "spec" => {
        "containers" => [
          {
            "name" => "node",
            "image" => "node:latest",
            "ports" => [
              {
                "containerPort" => 8080,
                "protocol" => "TCP"
              }
            ]
          }
        ]
      }
    }
  },
  "status" => {
    "latestVersion" => 0,
    "observedGeneration" => 0,
    "replicas" => 0,
    "updatedReplicas" => 0,
    "availableReplicas" => 0,
    "unavailableReplicas" => 0
  }
})

req_options = {
  use_ssl: uri.scheme == "https",
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end


  uri = URI.parse("https://ose.cpaas.service.test:8443/api/v1/namespaces/"+params[:project_name]+"/services")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Accept"] = "application/json,"
request["Authorization"] = TOKEN
request.body = JSON.dump({
  "kind" => "Service",
  "apiVersion" => "v1",
  "metadata" => {
    "name" => "node",
    "creationTimestamp" => nil,
    "labels" => {
      "app" => "node"
    },
    "annotations" => {
      "openshift.io/generated-by" => "OpenShiftNewApp"
    }
  },
  "spec" => {
    "ports" => [
      {
        "name" => "8080-tcp",
        "protocol" => "TCP",
        "port" => 8080,
        "targetPort" => 8080
      }
    ],
    "selector" => {
      "app" => "node",
      "deploymentconfig" => "node"
    }
  }
})

req_options = {
  use_ssl: uri.scheme == "https",
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end


  redirect_to visitors_path 
  end

  private

  def secure_params
    params.require(:project).permit(:project_name,:env,:db_name,:vcpu,:memory,:storage,:exp_date)
  end

end
