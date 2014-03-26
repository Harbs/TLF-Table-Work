/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package com.adobe.fxg;

import com.adobe.internal.fxg.sax.FXGSAXParser;
import static com.adobe.fxg.FXGConstants.*;

/**
 * A simple factory to create an instance of an FXGParser implementation.
 */
public class FXGParserFactory
{
    private FXGParserFactory()
    {
    }

    /**
     * Creates a new instance of the default implementation of FXGParser for Desktop.
     * 
     * @return an FXGParser instance
     * @see com.adobe.fxg.FXGParser 
     */
    public static FXGParser createDefaultParser()
    {
        return new FXGSAXParser(FXG_PROFILE_DESKTOP);
    }
    
    /**
     * Creates a new instance of the FXGParser implementation for Mobile.
     * 
     * @return an FXGParser instance
     * @see com.adobe.fxg.FXGParser 
     */
    public static FXGParser createDefaultParserForMobile()
    {
        return new FXGSAXParser(FXG_PROFILE_MOBILE);
    }
}
