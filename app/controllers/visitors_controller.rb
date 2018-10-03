class VisitorsController < ApplicationController
  
  layout 'project_layout'
   require 'net/http'
   require 'uri'
   require 'json'
   require 'openssl'
  TOKEN = "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJwZGZseSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJwZGZseS10b2tlbi1iaHNybiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJwZGZseSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImY2NTM5MGQxLWM2ZGEtMTFlOC1iMjczLTA2N2VlNjBmYTA2MCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpwZGZseTpwZGZseSJ9.O-fI5skvL9BT5Il4_iucugw9Qf6gzLwOxhJK-cR6t49vq7MwxBjnz1U5i_uJ-dcxDcAhoIE-q4I22cWLnk0h-7oksO8zbtlmpmxJgHpiHoi8v1-GEFD9nuGItxdknuVR_vjL8hkKoT4kDpBXbBPCrOYQNbbSU6_8dzx9-cb2fS8SrZi_CjhtFqZtn5mY85fLCH2TWrvzM8k_QdVZ69G9Orb6wVKfyv_VRpHvPzECXpEgCyvg2-1ZVoAORhGbJXcvzf9i5-lpCSdgGLGNPQeRKd7iHPspB5Ca3-gvs3nPir_LTyZS3U48KWWYqNDOPmZo66Wt1Y7IXO8L1UYXNfbuMQ"
    
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
    @visitor = current_user.build_project(secure_params)
    pvc_availble = PvContainer.where(pv_used: 0).first
    proj_name =  @visitor.try(:project_name)
    if @visitor.save
      p "=============#{proj_name} ===== project"
      p "================ #{TOKEN} =======token======"
      new_project_app(proj_name)
      project_policy_binding(proj_name, current_user.try(:lanid))
      git_url = git_repo_build(proj_name)
      @visitor.git_repo_url = git_url
      @visitor.save
      #test_pvc(proj_name, pvc_availble)
     # pvc_build_container(proj_name,pvc_availble)
      #pvc_availble.pv_used = 1
      #pvc_availble.project_name = @visitor.try(:project_name)
      #pvc_availble.save
      mysql_build_container(proj_name,pvc_availble)
      svc_build_container(proj_name)
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
    uri = URI.parse("https://loadbalancer1.fa6d.example.opentlc.com/oapi/v1/projectrequests")
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
    uri = URI.parse("https://loadbalancer1.fa6d.example.opentlc.com/oapi/v1/namespaces/"+project_name+"/rolebindings/admin")
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
    "system:serviceaccount:ruby-project:default",
    lanid
  ],
  "groupNames" => nil,
  "subjects" => [
    {
      "kind" => "ServiceAccount",
      "namespace" => "ruby-project",
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
  
    uri = URI.parse("http://gogs-pdgogs.apps.fa6d.example.opentlc.com/api/v1/user/repos?token=fbee2a55af6d02b5b4396a57b143dd1f3bb8899c")
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
   uri = URI.parse("https://loadbalancer1.fa6d.example.opentlc.com/oapi/v1/namespaces/"+project_name+"/deploymentconfigs")
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

  def svc_build_container(project_name)
   uri = URI.parse("https://loadbalancer1.fa6d.example.opentlc.com/api/v1/namespaces/"+project_name+"/services")
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
    uri = URI.parse("https://loadbalancer1.fa6d.example.opentlc.com/oapi/v1/projects/"+project.try(:project_name))
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
