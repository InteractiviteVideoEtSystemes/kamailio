#include "../../parser/parse_from.h"
#include "../../parser/parse_to.h"
#include "../../parser/parse_uri.h"
#include "../../parser/parser_f.h"
#include "../../ip_addr.h"
#include "../../resolve.h"
#include <string.h>

int is_from_internal_net(struct sip_msg* msg, struct net* net)
{
    switch ( matchnet( &msg->rcv.src_ip, net ) )
    {
	case 1:
	   /* print_ip("src_IP ", &msg->rcv.src_ip, " matches ");
	   print_net(net);
 	   LM_DBG("\n"); */
	   return 1;

	case 0:
	   return -1;

	case -1:
	   break;
    }	
    return -2;
}

int is_uri_in_internal_net(struct sip_uri * parsed_uri, struct net* net)
{
    struct dest_info dst;
    str* host;
    struct ip_addr dst_ip;
    
  
#ifdef HONOR_MADDR
    if (parsed_uri->maddr_val.s && parsed_uri->maddr_val.len)
    {
		host=&parsed_uri->maddr_val;
		DBG("maddr dst: %.*s:%d\n", parsed_uri->maddr_val.len, 
		    parsed_uri->maddr_val.s, parsed_uri->port_no);
    }  
    else
#endif
    {
	host=&parsed_uri->host;
    }
    
    if (sip_hostport2su(&dst.to, host, parsed_uri->port_no, &dst.proto) != 0)
    {
	ERR("failed to resolve \"%.*s\"\n", host->len, ZSW(host->s));
	return -4;
    }

    su2ip_addr( &dst_ip, &dst.to);
    switch ( matchnet( &dst_ip, net ) )
    {
	case 1:
	    //LM_INFO( "%.*s is in internal net.\n", host->len, host->s );
	    return 1;

	case 0:
	    //LM_INFO( "%.*s is in NOT internal net.\n", host->len, host->s );
	    return -1;

	default:
	    break;
    }
    return -2;
}

int is_uri_in_internal_net_str(str * uri, struct net* net)
{
    struct sip_uri parsed_uri;

    LM_DBG("Checking if dest %.*s is in internal net.\n",
	    uri->len, uri->s );
	    
    if ( uri->s )
    {
	if ( uri->len > 4 && strncmp( uri->s, "sip:", 4 ) == 0 )
	{
	    if ( parse_uri(uri->s, uri->len, &parsed_uri) < 0)
	    {
		LOG(L_ERR, "ERROR: is_uri_in_internal_net: bad_uri: %.*s\n",
		    uri->len, uri->s );
		return -3;
	    }
	}
	else
	{
	    // Assume string is the hostname
	    parsed_uri.maddr.s = NULL;
	    parsed_uri.maddr.len = 0;
	    parsed_uri.host = *uri;
	    parsed_uri.port_no = 5060;
	}
	return is_uri_in_internal_net(&parsed_uri, net);
    }
    return -1;
}
