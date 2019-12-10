int is_from_internal_net(struct sip_msg* msg, struct net* net);
int is_uri_in_internal_net(struct sip_uri * parsed_uri, struct net* net);
int is_uri_in_internal_net_str(str * uri, struct net* net);
