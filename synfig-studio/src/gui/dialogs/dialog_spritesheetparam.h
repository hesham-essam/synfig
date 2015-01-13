/* === S Y N F I G ========================================================= */
/*!	\file dialogs/dialog_spritesheetparam.h
**	\brief SpriteSheetParam
**
**	$Id$
**
**	\legal
**	Copyright (c) 2015 Denis Zdorovtsov
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

/* === S T A R T =========================================================== */

#ifndef __SYNFIG_STUDIO_DIALOG_SPRITESHEETPARAM_H
#define __SYNFIG_STUDIO_DIALOG_SPRITESHEETPARAM_H

/* === H E A D E R S ======================================================= */

#include "dialogs/dialog_targetparam.h"

/* === M A C R O S ========================================================= */

/* === T Y P E D E F S ===================================================== */

/* === C L A S S E S & S T R U C T S ======================================= */

namespace studio {
class Dialog_SpriteSheetParam: public Dialog_TargetParam
{
	public:
		Dialog_SpriteSheetParam(Gtk::Window &parent);
		~Dialog_SpriteSheetParam();

protected:
	virtual void init();
	virtual void write_tparam(synfig::TargetParam & tparam); 

private:

};

}; //studio

/* === E N D =============================================================== */

#endif 
