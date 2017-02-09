package com.moonpi.swiftnotes;


import android.support.test.espresso.ViewInteraction;
import android.support.test.rule.ActivityTestRule;
import android.support.test.runner.AndroidJUnit4;
import android.test.suitebuilder.annotation.LargeTest;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;

import org.hamcrest.Description;
import org.hamcrest.Matcher;
import org.hamcrest.TypeSafeMatcher;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import static android.support.test.espresso.Espresso.onData;
import static android.support.test.espresso.Espresso.onView;
import static android.support.test.espresso.action.ViewActions.*;
import static android.support.test.espresso.assertion.ViewAssertions.*;
import static android.support.test.espresso.matcher.ViewMatchers.*;
import static org.hamcrest.CoreMatchers.allOf;
import static org.hamcrest.CoreMatchers.anyOf;

import android.support.test.runner.AndroidJUnit4;
import android.widget.TextView;

// Import the Test Cloud Espresso extensions here

@LargeTest
@RunWith(AndroidJUnit4.class)
public class testCreateNote {

    @Rule
    public ActivityTestRule<MainActivity> mActivityTestRule = new ActivityTestRule<>(MainActivity.class);

    // Instantiate  your report helper here

    @Test
    public void testCreateFirstNote() {

        // Add label for navigating to new note screen
        onView(withId(R.id.newNote)).perform(click());

        // Add label for adding note title
        onView(withId(R.id.titleEdit)).perform(typeText("My first note"));

        // Add label for adding note content
        onView(withId(R.id.bodyEdit)).perform(typeText("Today I created my first note."));

        // Add label for pressing the back button
        onView(withContentDescription("Navigate up")).perform(click());

        // Add label for saying "yes" to save dialog
        onView(withText("Yes")).perform(click());

        // Add label for verifying the note was created
        onView(allOf(withText("My first note"))).check(matches(isDisplayed()));
    }

    @Test
    public void testCreateSecondNote() {

        // Add label for navigating to new note screen
        onView(withId(R.id.newNote)).perform(click());

        // Add label for adding note title
        onView(withId(R.id.titleEdit)).perform(typeText("Apples"));

        // Add label for adding note content
        onView(withId(R.id.bodyEdit)).perform(typeText("Oranges"));

        // Add label for pressing the back button
        onView(withContentDescription("Navigate up")).perform(click());

        // Add label for saying "yes" to save dialog
        onView(withText("Yes")).perform(click());

        // Add label for verifying the note was created
        // Note that we expect this test to fail since "Bananas" was not part of the note content
        onView(allOf(withText("Bananas"))).check(matches(isDisplayed()));
    }


    private static Matcher<View> childAtPosition(
            final Matcher<View> parentMatcher, final int position) {

        return new TypeSafeMatcher<View>() {
            @Override
            public void describeTo(Description description) {
                description.appendText("Child at position " + position + " in parent ");
                parentMatcher.describeTo(description);
            }

            @Override
            public boolean matchesSafely(View view) {
                ViewParent parent = view.getParent();
                return parent instanceof ViewGroup && parentMatcher.matches(parent)
                        && view.equals(((ViewGroup) parent).getChildAt(position));
            }
        };
    }
}
