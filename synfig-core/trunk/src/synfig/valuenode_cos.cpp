/* === S Y N F I G ========================================================= */
/*!	\file valuenode_cos.cpp
**	\brief Implementation of the "Cos" valuenode conversion.
**
**	$Id$
**
**	\legal
**	Copyright (c) 2002-2005 Robert B. Quattlebaum Jr., Adrian Bentley
**	Copyright (c) 2007 Chris Moore
**
**	This package is free software; you can redistribute it and/or
**	modify it under the terms of the GNU General Public License as
**	published by the Free Software Foundation; either version 2 of
**	the License, or (at your option) any later version.
**
**	This package is distributed in the hope that it will be useful,
**	but WITHOUT ANY WARRANTY; without even the implied warranty of
**	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
**	General Public License for more details.
**	\endlegal
*/
/* ========================================================================= */

/* === H E A D E R S ======================================================= */

#ifdef USING_PCH
#	include "pch.h"
#else
#ifdef HAVE_CONFIG_H
#	include <config.h>
#endif

#include "valuenode_cos.h"
#include "valuenode_const.h"
#include "general.h"

#endif

/* === U S I N G =========================================================== */

using namespace std;
using namespace etl;
using namespace synfig;

/* === M A C R O S ========================================================= */

/* === G L O B A L S ======================================================= */

/* === P R O C E D U R E S ================================================= */

/* === M E T H O D S ======================================================= */

ValueNode_Cos::ValueNode_Cos(const ValueBase &value):
	LinkableValueNode(value.get_type())
{
	switch(value.get_type())
	{
	case ValueBase::TYPE_REAL:
		set_link("angle",ValueNode_Const::create(Angle::deg(0)));
		set_link("amp",ValueNode_Const::create(value.get(Real())));
		break;
	default:
		throw Exception::BadType(ValueBase::type_local_name(value.get_type()));
	}

	DCAST_HACK_ENABLE();
}

LinkableValueNode*
ValueNode_Cos::create_new()const
{
	return new ValueNode_Cos(get_type());
}

ValueNode_Cos*
ValueNode_Cos::create(const ValueBase &x)
{
	return new ValueNode_Cos(x);
}

ValueNode_Cos::~ValueNode_Cos()
{
	unlink_all();
}

ValueBase
ValueNode_Cos::operator()(Time t)const
{
	return
		Angle::cos(
			(*angle_)(t).get(Angle())
		).get() * (*amp_)(t).get(Real())
	;
}


String
ValueNode_Cos::get_name()const
{
	return "cos";
}

String
ValueNode_Cos::get_local_name()const
{
	return _("Cos");
}

bool
ValueNode_Cos::check_type(ValueBase::Type type)
{
	return type==ValueBase::TYPE_REAL;
}

bool
ValueNode_Cos::set_link_vfunc(int i,ValueNode::Handle value)
{
	assert(i>=0 && i<link_count());

	switch(i)
	{
	case 0: CHECK_TYPE_AND_SET_VALUE(angle_, ValueBase::TYPE_ANGLE);
	case 1: CHECK_TYPE_AND_SET_VALUE(amp_,   ValueBase::TYPE_REAL);
	}
	return false;
}

ValueNode::LooseHandle
ValueNode_Cos::get_link_vfunc(int i)const
{
	assert(i>=0 && i<link_count());

	if(i==0)
		return angle_;
	if(i==1)
		return amp_;

	return 0;
}

int
ValueNode_Cos::link_count()const
{
	return 2;
}

String
ValueNode_Cos::link_name(int i)const
{
	assert(i>=0 && i<link_count());

	if(i==0)
		return "angle";
	if(i==1)
		return "amp";
	return String();
}

String
ValueNode_Cos::link_local_name(int i)const
{
	assert(i>=0 && i<link_count());

	if(i==0)
		return _("Angle");
	if(i==1)
		return _("Amplitude");
	return String();
}

int
ValueNode_Cos::get_link_index_from_name(const String &name)const
{
	if(name=="angle")
		return 0;
	if(name=="amp")
		return 1;

	throw Exception::BadLinkName(name);
}
