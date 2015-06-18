/* 
 * File:   ul_scscf_stats.h
 * Author: jaybeepee
 *
 * Created on 24 May 2015, 11:15 AM
 */

#ifndef UL_SCSCF_STATS_H
#define	UL_SCSCF_STATS_H

#include "../../counters.h"

struct ul_scscf_counters_h {
    counter_handle_t active_subscriptions;
    counter_handle_t active_impus;
    counter_handle_t active_contacts;
};

int ul_scscf_init_counters();
void ul_scscf_destroy_counters();

#endif	/* UL_SCSCF_STATS_H */



