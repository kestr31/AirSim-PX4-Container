std::string getEnv( const std::string& var ) {
     const char * val = std::getenv( var.c_str() );
     if ( val == nullptr ) {
         msr::airlib::MultirotorRpcLibClient client;
         std::cout << "NO IP SET. DEFAULTING TO LOCALHOST." << "\n";
         return "";
     } else {
         msr::airlib::MultirotorRpcLibClient client(val);
         std::cout << "IP SET: " << val << "\n";
         return val;
     }
}

string airsimAddress=getEnv("AIRSIM_IP");
msr::airlib::MultirotorRpcLibClient client(airsimAddress);