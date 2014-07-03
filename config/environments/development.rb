Dor::Config.configure do

  workflow.url 'https://lyberservices-dev.stanford.edu/workflow/'

  robots do 
    workspace '/tmp'
  end
  
  demoConfig do
    
  end

  dor do
    service_root 'https://USERNAME:PASSWORD@lyberservices-dev.stanford.edu/dor'
  end
   
end

REDIS_URL ||= "lyberservices-dev.stanford.edu:6379/resque:#{ENV['ROBOT_ENVIRONMENT']}"
