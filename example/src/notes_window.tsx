import React, { useState } from 'react';
import { View, Text, TextInput, StyleSheet } from 'react-native';

export default function NotesWindow() {
  console.log('[NotesWindow] Rendering');
  const [text, setText] = useState('');
  return (
    <View style={[styles.container, { backgroundColor: '#fff' }]}>
      <Text style={[styles.title, { color: '#000' }]}>📝 Notes</Text>
      <TextInput
        style={styles.textInput}
        multiline
        value={text}
        onChangeText={(v) => {
          console.log('[NotesWindow] onChangeText:', v.length, 'chars');
          setText(v);
        }}
        placeholder='Type notes here...'
        placeholderTextColor='#999'
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: { fontSize: 20, fontWeight: 'bold', color: '#000' },
  textInput: {
    flex: 1,
    width: '100%',
    marginTop: 12,
    padding: 10,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 6,
    fontSize: 14,
    color: '#000',
    backgroundColor: '#fff',
    textAlignVertical: 'top',
  },
});
